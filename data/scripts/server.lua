-- ----------------------------------------------------------------------------
-- 
-- Workfile: server.lua
-- Created by: Plus
-- Copyright (C) 2000-2003 Targem Ltd. All rights reserved.
-- 
-- Global server related stuff. This script is executed on server init,
-- from CServer::Init().
-- 
-- ----------------------------------------------------------------------------
--  $Id: server.lua 86 2007-02-28 12:25:04Z phosgen $
-- ----------------------------------------------------------------------------

anticheat = 0

-- include cheats.lua
EXECUTE_SCRIPT "data\\scripts\\cheats.lua"

-- include debug.lua
EXECUTE_SCRIPT "data\\scripts\\debug.lua"

-- include AIReader.lua
EXECUTE_SCRIPT "data\\scripts\\AIReader.lua"


-- include dialoghelpers.lua
EXECUTE_SCRIPT "data\\scripts\\dialoghelpers.lua"

-- include queststates.lua
EXECUTE_SCRIPT "data\\scripts\\queststates.lua"

-- include mapfunc.lua
EXECUTE_SCRIPT "data\\scripts\\mapfunc.lua"

-- global object repository
g_ObjCont = GET_GLOBAL_OBJECT "g_ObjContainer"

if not g_ObjCont then
		  LOG "Could not find global g_ObjContainer!!!"
end

-- global quest info manager
g_QuestStateManager = GET_GLOBAL_OBJECT "g_QuestStateManager"

if not g_QuestStateManager then
		  LOG "Could not find global g_QuestStateManager!!!"
end

-- global quest info manager
-- g_Player = GetPlayer()

-- if not g_Player then
--		LOG "Could not find global GetPlayer()!!!"
-- end


LEVEL_SIZE = 8*32.0
g_Level = GET_GLOBAL_OBJECT "CurrentLevel"
if g_Level then
		  LEVEL_SIZE = g_Level:GetLandSize()*32.0
else
end


-- Initializes global player. Called from code when the map is loaded
function InitPlayer()
		  g_Player = GetPlayer()

		  if not GetPlayer() then
					 LOG "Could not find global GetPlayer()!!!"
		  else
					 GameFiltersUse()
		  end
end


-- shortcut: returns Game Object via name
function GetEntityByName( name )
		  return g_ObjCont:GetEntityByObjName( name )
end


-- shortcut: returns Game Object via ID
function GetEntityByID( id )
		  return g_ObjCont:GetEntityByObjId( id )
end


-- shortcut: creates Game Object and all it's children, returns it's handler (ID)
local function _CreateNewObject( prototypeName, objName, parentId, belong )
		  local prototypeId = g_ObjCont:GetPrototypeId( prototypeName )

		  return g_ObjCont:CreateNewObject( prototypeId, objName, parentId, belong )
end


-- shortcut: object constructor
function CreateNewObject( arg )
		  if not arg.parentId then 
					 arg.parentId = -1 
		  end
		  
		  if not arg.belong then 
					 arg.belong = 1001 
		  end
		  
		  return _CreateNewObject( arg.prototypeName, arg.objName, arg.parentId, arg.belong )
end


-- these ought to match those ones in Relationship.h
RS_ENEMY		  = 1
RS_NEUTRAL		= 2
RS_ALLY			= 3
RS_OWN			 = 4


-- safe object remove
function RemoveObject( GameObject )
		  GameObject:Remove()
		  GameObject = nil
end


function SafeRemove( GameObject )
	local o = getObj( GameObject )
	if o then 
		RemoveObject( o )
	end
end	


--Activate trigger
function TActivate( TriggerName )
		  local trig1 = GetEntityByName(TriggerName)
		  if trig1 then 
					 trig1:Activate() 
		  end
end


--Deactivate trigger
function TDeactivate( TriggerName )
		  local trig1 = GetEntityByName(TriggerName)
		  if trig1 then 
					 trig1:Deactivate() 
		  end
end


function SetVar(Name, Value)
		  local trig1 = GetEntityByName("GlobalVar")
		  if trig1 then 
					 local tmpv=Value
					 if type(Value)=="table" then
								tmpv=Value[1]
								for i=2,getn(Value) do
										  tmpv=tmpv.." "..Value[i]
								end
					 end
					 local GAIParam v = tmpv
					 trig1:SetVar(Name, v ) 
		  end
end


function GetVar(Name)
		  local trig1 = GetEntityByName("GlobalVar")
		  if trig1 then 
					 return trig1:Var(Name) 
		  else
					 return nil
		  end
end


function SetTolerance( ID1, ID2, Tol )
		  g_ObjCont:SetTolerance( ID1, ID2, Tol )
end


function GetTolerance( ID1, ID2 )
		  return g_ObjCont:GetTolerance( ID1, ID2 )
end


function IncTolerance( ID1, ID2, Tol )
		  g_ObjCont:IncTolerance( ID1, ID2, Tol )
end


function GetHeight ( x, z )
	return g_ObjCont:GetHeight( x, z )
end


CINEMATIC_AIM_TO_ID	  = 1
CINEMATIC_AIM_TO_POINT  = 2
CINEMATIC_FROM_POS				  = 3
CINEMATIC_NO_AIM					 = 4

function FlyLinked( PathName, Id, PlayTime, StartFade, EndFade, LookToId, VisPanel, RelativeRotations, 
		  WaitWhenStop, InterpolateFromPrevious )
		  
		  local cinematic = GetCinematic()
		  RuleConsole("FogOfWar 0")		 

		  SetCinematicFadeParams( StartFade, EndFade )

		  ChangeMode("GS_CINEMATIC")
		  --cinematic:ResetAim()
		  
		  if VisPanel ~= nil then
					 SetCinematicCinemaPanel( VisPanel )
		  else
					 SetCinematicCinemaPanel( 1 )
		  end

		  cinematic:Load("camera_paths.xml")
		  cinematic:SetPath(PathName)	  

		  cinematic:SetRelativePoints(1)
		  cinematic:SetRelativeRotations(0)
		  cinematic:SetBaseToId(Id)

		  if LookToId then
					 cinematic:SetAimToID( LookToId )
					 cinematic:SetLookTo( true )
		  else
					 cinematic:SetRelativeRotations(  RelativeRotations )
					 cinematic:SetLookTo( false )
		  end

		  cinematic:SetWaitWhenStop( WaitWhenStop )
		  cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )

		  cinematic:Play( PlayTime )
end

-- Регистрирует вращение камеры
function FlyAround( Phi, Theta, Radius, PlayTime, curPos, Id, StartFade, EndFade, PathName, VisPanel,
		  WaitWhenStop, InterpolateFromPrevious )
		  
		  local cinematic = GetCinematic()
		  RuleConsole("FogOfWar 0")

		  SetCinematicFadeParams( StartFade, EndFade )
		  
		  if not cinematic then
					 println( "Error: couldn't get cinematic" )
					 return
		  end
		  
		  if not PathName then
					 PathName = ""
		  end	  

		  ReadyCinematic()		  
		  cinematic:SetAimToID(Id)

		  if VisPanel then
					 SetCinematicCinemaPanel( VisPanel )
		  else
					 SetCinematicCinemaPanel( 1 )
		  end

		  cinematic:SetWaitWhenStop( WaitWhenStop )
		  cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )

		  cinematic:FlyAround( Phi, Theta, Radius, PlayTime, curPos, PathName )
end

-- Регистрирует пролет камеры по пути
function Fly( PathName, AimType, Target, Time, StartFade, EndFade, VisPanel,
		  WaitWhenStop, InterpolateFromPrevious )
		  
		  local cinematic = GetCinematic()
		  RuleConsole("FogOfWar 0")

		  if not cinematic then
					 println( "Error: couldn't get cinematic" )
					 return
		  end

		  if not StartFade then
					 println( "Error: StartFade parameter missing" )
					 return
		  end

		  if not EndFade then
					 println( "Error: EndFade parameter missing" )
					 return
		  end
		  
--		ReadyCinematic()
		  cinematic:Load("camera_paths.xml")
		  SetCinematicFadeParams( StartFade, EndFade )
		  ChangeMode("GS_CINEMATIC")
		  --cinematic:ResetAim()

		  if VisPanel ~= nil then
					 SetCinematicCinemaPanel( VisPanel )
		  else
					 SetCinematicCinemaPanel( 1 )
		  end

		  --cinematic:SetPath(PathName)

		  if AimType == CINEMATIC_AIM_TO_ID then 
					 cinematic:SetAimToID( Target )
					 cinematic:SetLookTo( true )
		  end
		  
		  if AimType == CINEMATIC_AIM_TO_POINT then 
					 cinematic:SetAim( Target )
					 cinematic:SetLookTo( true )
		  end	  
		  
		  if AimType == CINEMATIC_FROM_POS or AimType == CINEMATIC_NO_AIM then 
					 cinematic:SetLookTo( false )
		  end
		  
		  if AimType == CINEMATIC_FROM_POS then 
					 local pos, rot, lookAt = GetCameraPos()
					 cinematic:SetPathFromPos( pos, rot, PathName )
		  else
					 cinematic:SetPath( PathName )
		  end

		  cinematic:SetRelativePoints( false )
		  cinematic:SetRelativeRotations( false )

		  cinematic:SetWaitWhenStop( WaitWhenStop )
		  cinematic:SetLerpFromPreviousItem( InterpolateFromPrevious )
		  
		  cinematic:Play(Time)				
end

-- Запускает все зарегистрированные ролики на проигрывание
function StartCinematic()
		  local cinematic = GetCinematic()
		  cinematic:StartCinematic()
		  
		  if g_CinemaPanel then
					 g_CinemaPanel:ClearMessages()	
		  end
		  
		  UpdateCinematic( 0 ) -- by Anton: don't touch this!
end

-- Подготавливает игру к проигрыванию скриптового ролика
function ReadyCinematic()
		  local cinematic = GetCinematic()
		  
		  if not cinematic then
					 println( "Error: couldn't get cinematic" )
					 return
		  end

		  cinematic:Load("camera_paths.xml")
		  ChangeMode("GS_CINEMATIC")
end


function FlyStandard( PathName, Time )
		  Fly( PathName, CINEMATIC_NO_AIM, nil, Time, 1, 1 )
end



-- shortcut: Play Camera rout	
function FlyCamera( PathName, AimType, Target, Time, StartFade, EndFade )
		  Fly( PathName, AimType, Target, Time, StartFade, EndFade )
end


function FlyCameraHoldMode( PathName, AimType, Target, Time )
		  Fly( PathName, AimType, Target, Time, 1, 0 )
end


function GameCamera()
		  ChangeMode("GS_GAME")
		  EndCinematic()
		  if (GetVar("PlayerModel").AsInt == 1) then
					 ShowPlayerModel(1)
					 SetVar("PlayerModel", 2)
		  end								 
		  local oldSpeed = GetVar("Speed").AsFloat
		  if oldSpeed == 0 then
			 oldSpeed = 1 
		  end
		  SetGameSpeed( oldSpeed )
		  local IsSetCameraPos = GetVar("IsSetCameraPos").AsInt
		  if IsSetCameraPos == 1 then
					 SetCameraPos(GetVar("campos").AsVector, GetVar("yaw").AsFloat, GetVar("pitch").AsFloat, GetVar("roll").AsFloat)
--				  println("IsSetCameraPos")
		  end
		  SetVar("IsSetCameraPos",0)
-- Удаление актеров							
		  local DA = getObj("Destroy_Actors")
		  if not(DA) then 
					 RemoveAPlayer() 
		  else
					 DA:SetVar( "NPCID", 0 )
					 DA:Activate()
		  end
--		Работа с авто-НПС после npc_fly
		  local NPCID = GetVar( "NPCID" ).AsInt
--		println(NPCID)  
		  if ( NPCID > 0 ) then
					 SetVar( "NPCID", 0 )
					 if GetEntityByID( NPCID ) then
								GetEntityByID( NPCID ):AddModifier( "Belong", "= "..tostring( GetVar( "NPCBelong" ).AsInt ) )
								if GetVar( "NPCH" ).AsInt == 1 then 
										  if DA then
													 DA:SetVar( "NPCID", NPCID )
										  else
													 GetEntityByID( NPCID ):Hide() 
										  end
								end
					 end
		  end
end


-- Constants for units animations
AT_STAND1					=		 0
AT_STAND2					=		 1
AT_MOVE1					 =		 2
AT_MOVE2					 =		 3
AT_ATTACK1				  =		 4
AT_ATTACK2				  =		 5
AT_PAIN1					 =		 6
AT_PAIN2					 =		 7
AT_DEATH1					=		 8
AT_DEATH2					=		 9
AT_BLOCK1					=		 10
AT_BLOCK2					=		 11
AT_RESERVED1	 =		 12
AT_RESERVED2	 =		 13
AT_RESERVED3	 =		 14
AT_RESERVED4	 =		 15

function getObj( name )
		  local obj = nil
		  if type(name) == "string" then
					 obj = GetEntityByName( name )
		  else if type(name) == "number" then 
								obj = GetEntityByID( name )
					 else
								obj = name
				end
		  end
		  return obj
end


function GetCurNpc()
		  return GET_GLOBAL_OBJECT "g_CurrentNpc"
end

Q_UNKNOWN					=		 0
Q_CANBEGIVEN	 =		 1
Q_TAKEN					  =		 2
Q_COMPLETED				 =		 3
Q_FAILED					 =		 4

function QuestStatus(name)
-- возвращает статус квеста с именем name
-- 0 - квест не взят и не может быть дан
-- 1 - квест может быть дан
-- 2 - квест дан (но не выполнен и не провален)
-- 3 - квест выполнен
-- 4 - квест провален
		  local Stat=Q_UNKNOWN
		  if				  CanQuestBeGiven(name)	then Stat=Q_CANBEGIVEN
		  elseif  IsQuestFailed(name)				 then Stat=Q_FAILED
		  elseif  IsQuestComplete(name)	then Stat=Q_COMPLETED
		  elseif  IsQuestTaken(name)				  then Stat=Q_TAKEN
		  end
		  return Stat
end

function TeamCreate()
		  println("TeamCreate isn't correct command. You have to use CreateTeam")
		  LOG("TeamCreate isn't correct command. You have to use CreateTeam")
end

function CreateTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares)
-- Создает команду машин из списка ListOfVehicle, с именем Name и белонгом Belong, в позиции CreatePos.
-- Т.к. машин можно создавать несколько, то и позицию каждой машинки можно указывать
-- (если задать CreatePos массивом), иначе машины выстоятся в ряд по оси Z (друг за другом). 
-- Eсли надо кудато ехать, то надо указать WalkPos
-- возвращает указатель на созданную команду(если все ок), либо 0 - если ошибка
-- IsWares - 1 генерировать в машины случайный товар
-- Rotate - начальный угол поворотома машин
-- Пример:
-- TeamCreate("ExtrGuardTeam",1012,CVector(985.260, 306.000, 2541.873),{"Revolutioner1","Revolutioner2","Bug01","Bug01","Revolutioner2"})
-- Будет создана команда из 5 машин. У команды будет имя ExtrGuardTeam, а у машин
-- ExtrGuardTeam_vehicle_0, ExtrGuardTeam_vehicle_1, .. ExtrGuardTeam_vehicle_4.
	 if CreatePos==nil then
		  LOG("No position")
		  return
	 end
	 
	 local _CreatePos=CreatePos
	 if type(CreatePos)=="table" then
					 _CreatePos=CreatePos[1]
	 end
		
		local dir  = CVector( 1, 0, 0 )
	 if WalkPos and CreatePos then
	 	dir = ( WalkPos - CreatePos ):normalize()
		 dir.y = 0
	  end

		  local teamID = CreateNewObject{
								prototypeName = "team",
								objName = Name,
								belong = Belong
					 }
		  local team=GetEntityByID(teamID)
		  if team then
--			println("team created")
			  local i=1
			  local id=0
			  while ListOfVehicle[i] do
					  local id = CreateNewObject{
																prototypeName = ListOfVehicle[i],
																objName = Name.."_vehicle_"..i-1,
																belong = Belong
													 }
					  local vehicle = GetEntityByID(id)
					  if vehicle then
								vehicle:SetRandomSkin()
								if IsWares==1 then
										  local mapNum = 0
										  local mapName = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLevelName()
										  if			mapName == "r5m1" then mapNum = 1
										  elseif mapName == "r5m2" then mapNum = 4
										  elseif mapName == "r6m1" then mapNum = 6
										  elseif mapName == "r6m2" then mapNum = 8
										  end

										  local RandWarez = {"potato","firewood","scrap_metal","oil","fuel","machinery","bottle","tobacco","book","electronics"}
										  local r = random(2) + mapNum

										  vehicle:AddItemsToRepository(RandWarez[r], 1)
								end
								
								-- by Anton: это не нужно, т.к. вызываем SetGamePositionOnGround()
								-- CreatePos.y = g_ObjCont:GetHeight(CreatePos.x, CreatePos.z) + 1.3 * vehicle:GetSize().y
								vehicle:SetDirection(dir)
								
						  if type(CreatePos)=="table" then
								if CreatePos[i]~=nil then _CreatePos=CreatePos[i] end
					 end


								vehicle:SetGamePositionOnGround(_CreatePos)
								team:AddChild(vehicle)

								local vh_length=1.7 * vehicle:GetSize().z
								_CreatePos.z=_CreatePos.z+vh_length
					  end
					  i = i + 1
			  end
		  else
			  println("Error: Can't create team !!!")
--			team:Remove()
			  return 0
		  end
					 if WalkPos then
								team:SetDestination(WalkPos)
					 end
		  return team
end


function CreateCaravanTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, IsWares, Rotate)
-- Создает команду-караван машин из списка ListOfVehicle
-- см. CreateTeam()
	 if CreatePos==nil then
		  LOG("No position")
		  return
	 end
	 
	 local _CreatePos=CreatePos

	 if type(CreatePos)=="table" then
					 _CreatePos=CreatePos[1]
	 end

		local dir  = CVector( 1, 0, 0 )
	 if WalkPos and CreatePos then
	 	dir = ( WalkPos - CreatePos ):normalize()
		 dir.y = 0
	  end


	 if Rotate~=nil then
				if type(Rotate)=="table" then
								_Rotate=Rotate[1]
					 else
								_Rotate=Rotate
				end
		  end

		  local teamID = CreateNewObject{
								prototypeName = "caravanTeam",
								objName = Name,
								belong = Belong
					 }
		  local team=GetEntityByID(teamID)
		  if team then
--			println("team created")
			  local i=1
			  local id=0
			  while ListOfVehicle[i] do
					  local id = CreateNewObject{
																prototypeName = ListOfVehicle[i],
																objName = Name.."_vehicle_"..i-1,
																belong = Belong
													 }
					  local vehicle = GetEntityByID(id)
					  if vehicle then
								vehicle:SetRandomSkin()
								if IsWares==1 then
										  local RandWarez = {"potato","firewood","scrap_metal","oil","fuel","machinery","bottle","tobacco","book","electronics"}
										  local r = random(10)

										  vehicle:AddItemsToRepository(RandWarez[r], 1)
								end
								
								-- by Anton: это не нужно, т.к. вызываем SetGamePositionOnGround()
								-- CreatePos.y = g_ObjCont:GetHeight(CreatePos.x, CreatePos.z) + 1.3 * vehicle:GetSize().y

								vehicle:SetDirection(dir)
								
						  if type(CreatePos)=="table" then
								if CreatePos[i]~=nil then _CreatePos=CreatePos[i] end
					 end


								vehicle:SetGamePositionOnGround(_CreatePos)
								team:AddChild(vehicle)

								local vh_length=1.7 * vehicle:GetSize().z
								_CreatePos.z=_CreatePos.z+vh_length
					  end
					  i = i + 1
			  end
		  else
			  println("Error: Can't create team !!!")
--			team:Remove()
			  return 0
		  end
					 if WalkPos then
								team:SetDestination(WalkPos)
					 end
		  return team
end

function IsAlive( obj )  -- принимает строки-ИД- объекты имеющие метод IsAlive()
	local res = false
	local obj_ = obj	
	obj_ = getObj( obj_ )
	if obj_ then
--		LOG(obj_:GetClassName() .."	---	" .. obj_:GetId()  )
			if obj_:GetClassName() == "Team" then
			  for i =1, obj_:GetNumVehicles() do
			  	res = res or IsAlive( obj_:GetVehicle( i - 1 ) )
		  	end
			else
				res = obj_:IsAlive()
			end
	end
	return res
end;
function IsAliveT( obj )  -- tabl
	local res = false
	local obj_ = obj	
	if type( obj_ ) == "table" then
		for i, v in obj_ do
			res = res or IsAlive( v )
		end
	end	
	return res
end;


-- Расстояние между двумя объектами
function Dist(obj1_, obj2_)
		  local L = nil
  			local obj1 = getObj( obj1_ )
  			local obj2 = getObj( obj2_ )

--		  if not(obj1) or not(obj2) then
--					 println ("ERROR! Zero-Object...")
--		  end

		  if obj1 and obj2 then 
		  	L = (obj1:GetPosition() - obj2:GetPosition()):length()
		  end

		  return L
end

function getPos(name)
		  local obj=getObj(name)
		  if obj then
			  local pos=obj:GetPosition()
			  return pos
		  else
					 return nil
		  end
end

function GetPos(name)
		  return getPos(name)
end

function setPos( name, position )
		  local obj = getObj( name )
		  if obj then 
					 if obj:GetClassName()=="Vehicle" then
								obj:SetGamePositionOnGround( position )
					 else
								obj:SetPosition( position )
					 end
					 return position
		  else
					 return nil
		  end
end

function SetPos( name, position )
		  return setPos(name, position)
end


function setRot(name, rotation)
		  local obj = getObj( name )
		  if obj then 
					 obj:SetRotation(rotation)
					 return rotation
		  else
					 return nil
		  end
end


-- Значение Фильтров в Игровом режиме
function GameFiltersUse()
--							 g_EnableBloom (true, 0.75, 0.25)

--							 g_EnableBloom (false)
--							 g_EnableMotionBlur (false)

--							 g_EnableBloom( GetProfileBloom() )
--							 g_EnableMotionBlur( GetProfileMotionBlur(), GetProfileMotionBlurAlpha() )
end

-- Значение Фильтров в Кинематографическом режиме
function CinemaFiltersUse()
--							 g_EnableBloom (true, 0.75, 0.55)
--							 g_EnableMotionBlur (true, 0.25)
end

-- special function for creating vehicle
function CreateVehicle( PrototypeName, Belong, pos, NameVehicle)

		  -- Create name of vehicle
		  local nameVeh

		  if NameVehicle then
					 nameVeh = NameVehicle
		  else
					 nameVeh = "Vehicle"..tostring(random(9999))
		  end

		  -- Create vehicle
		  local id = CreateNewObject{
					 prototypeName = PrototypeName,
					 objName = nameVeh,
					 belong = Belong
		  }

		  local vehicle = GetEntityByID( id )
		  println(vehicle:GetName())

		  -- by Anton: это не нужно, т.к. вызываем SetGamePositionOnGround()
		  -- local hover = 1.5 * vehicle:GetSize().y
		  -- pos.y = g_ObjCont:GetHeight( pos.x, pos.z ) + hover

		  vehicle:SetGamePositionOnGround( pos )


		  -- Add vehicle to some team
		  local teamId = CreateNewObject{
					 prototypeName = "team",
					 objName = "Team"..tostring(random(9999)),
					 belong = Belong
		  }

		  local team = GetEntityByID( teamId )

		  if not team then
					 println( "Error: coundn't create team" )
					 return nil
		  end

		  team:AddChild( vehicle )

		  println( "Vehicle created. id = "..tostring(id) )

		  return team
end

-- special function for creating humans
function CreateHuman( PrototypeName, Belong, Pos, HumanName, PathName )

		  -- Create name of Human
		  local nameHuman

		  if HumanName then
					 nameHuman = HumanName
		  else
					 nameHuman = "Human"..tostring(random(9999))
		  end

		  -- Create human belong  
		  local bel

		  if belong then
					 bel = belong
		  else
					 bel = 1100
		  end

		  -- Create human
		  local id = CreateNewObject{
					 prototypeName = PrototypeName,
					 objName = nameHuman,
					 belong = bel
		  }

		  local human = GetEntityByID( id )
		  
		  if not human then
					 println( "Error: human ".. PrototypeName .. " is not created" )
					 return nil
		  end

--		Pos.y = g_ObjCont:GetHeight( Pos.x, Pos.z )

		  human:SetPosition( Pos )

		  if PathName then
					 if not human:AddWalkPathByName( PathName  ) then
								println( "Error: path ".. PathName .." for human ".. nameHuman .. " is not added" )
								return nil
					 end
		  
					 if not human:SetWalkPathByName( PathName  ) then
								println( "Error: path ".. PathName .." for human ".. nameHuman .. " is not set" )
								return nil
					 end
		  end

		  return human
end


function GetItemsAmount(name)
-- Функция возвращает кол-во едениц товара name в машине игрока
--		local pl=GetPlayerVehicle():GetParent()
		  local pl=GetPlayerVehicle()
		  if pl then
--			println("Player live")
			  local i=0
			  while pl:HasAmountOfItemsInRepository( name,i+1 ) == 1 do
								i = i + 1
			  end
--			println( "Get result = "..tostring(i) )
			  return i
		  end
		  return nil
end

function AddPlayerItems(name, count)
-- Добавляет игроку count едениц товара name.
-- Возвращает кол-во положеных едениц товара
-- Если у игрока не хватает места под указанное кол-во, то кладется сколько влезет
		  if count==nil or 0>count then count=1 end
--		local pl=GetPlayerVehicle():GetParent()
		  local pl=GetPlayerVehicle()
		  if pl then
					 local i = count
					 while (pl:AddItemsToRepository(name,i) == nil) and (i>=1) do
								i = i - 1
					 end
--				  println( "Add result = "..tostring(i))
					 if 0>=i then
								return nil
					 else
								return i
					 end
		  end
end

function AddPlayerItemsWithBox(name, count, boxtype, pos)
-- Добавляет игроку count едениц товара name.
-- Если весь товар не влазит, то создает контейнер в  pos, и туда докладывает не влезший в машину
-- boxtype - тип бокса (зарезервированно покачто)
		  local WasAdd=AddPlayerItems(name, count)
		  if WasAdd==nil then WasAdd=0 end
		  if count==nil or 0>count then count=1 end
--		println("WasAdd = "..WasAdd.." Count = "..count)
		  if count>WasAdd then
--		println("count>WasAdd")
					 local chestID = CreateNewObject{		  prototypeName = "someChest",
																													 objName = "ItemsChest"..random(1000)
																									}	 
					 local MyChest=GetEntityByID(chestID)
					 if pos==nil then
								pos = CVector(GetPlayerVehicle():GetPosition())
								pos.z = pos.z + GetPlayerVehicle():GetSize().z + 1
					 end
					 MyChest:SetPosition(pos)
--				  println("pos = "..pos)
					 for i=WasAdd+1, count do
--							 println(" i = "..i)
								local itemID = CreateNewObject{ prototypeName = name,
																																objName = name..random(1000)
																											  }
								local MyItem = GetEntityByID(itemID)
								if MyChest and MyItem then
									MyChest:AddChild(MyItem)
				end
					 end
	end
end

function RemovePlayerItem(name, count)
-- Функция убирает count едениц товара name из машины игрока
	 if count==nil or 0>count then count=1 end
--		local pl=GetPlayerVehicle():GetParent()
		  local pl=GetPlayerVehicle()
		  if pl then
--			println("Player live")
			  local res=pl:RemoveItemsFromRepository(name, count)
			  return res
		  else
					 return nil
		  end
end

function AddChildByPrototype( obj, protName)
	 local myobj = getObj(obj)
	 if myobj then
					 if type(protName) == "string" then
								local pr_id = CreateNewObject{
																													 prototypeName = protName,
																													 objName = protName..random(10000)
																									}	 
								local mych = GetEntityByID( pr_id )
								if mych then
										  if myobj then 
													 myobj:AddChild( mych )
										  end
								end
					 elseif type(protName) == "table" then
								local i = 1
								while protName[i] do
										  local id = CreateNewObject{
																																prototypeName = protName[i],
																																objName = protName[i]..random(10000)
																											  }	 
										  local child = GetEntityByID( id )
										  if myobj then 
													 myobj:AddChild( child )
										  end
										  i = i+1
								end							
					 end
		  end
end

-- Функция создает Дамми обжект с заданной моделью
function CreateNewDummyObject( modelName, objName, parentId, belong, pos, rot, skin )
		  local prototypeName	  =		 "someDummyObject"
		  local dObj				  =		 _CreateNewObject( prototypeName, objName, parentId, belong )
		  local obj					=		 GetEntityByID (dObj)

		  if skin == nil then skin = 0 end

		  obj:SetModelName( modelName )
		  if rot then
					 obj:SetRotation ( rot )
		  end
		  obj:SetPosition ( pos )
		  if skin then
					 obj:SetSkin ( skin )
		  end

		  return dObj
end

-- Функция создает физичный Дамми обжект с заданной моделью
function CreateNewPhysicDummyObject( modelName, objName, parentId, belong, pos, rot, skin, mass )
		  local prototypeName	  =		 "physicDummyObject"
		  local dObj							 =		 _CreateNewObject( prototypeName, objName, parentId, belong )
		  local obj							  =		 GetEntityByID (dObj)

		  if skin == nil then skin = 0 end
		  if rot == nil then rot = Quaternion(0, 0, 0, 1) end
		  if mass == nil then mass = 100 end

		  obj:SetModelName( modelName )

		  obj:SetRotation ( rot )
		  obj:SetPosition ( pos )
		  obj:SetSkin ( skin )
		  obj:SetMass( mass )
		  
		  return obj
end

-- Функция создает Breakable обжект с заданной моделью
function CreateNewBreakableObject(prototypeName, objName, belong, pos, rot,skin)
		  local parentId = -1
		  local dObj				  =		 _CreateNewObject( prototypeName, objName, parentId, belong )
		  local obj					=		 GetEntityByID (dObj)

		  if skin == nil then skin = 0 end
		  
		  obj:SetRotation ( rot )
		  obj:SetPosition ( pos )
		  obj:SetSkin ( skin )
end


-- Функция создает SgNodeObject с заданной моделью
function CreateNewSgNodeObject( modelName, objName, parentId, belong, pos, rot , scale)
		  local prototypeName =	"SgNodeObject"
		  local dObj							 =		 _CreateNewObject( prototypeName, objName, parentId, belong )
		  local obj							  =		 GetEntityByID (dObj)

		  obj:SetSgNode( modelName )
		  if rot then
					 obj:SetRotation ( rot )
		  else
					 obj:SetRotation (Quaternion(0.0000, 0.0000, 0.0000, 1.0000))
		  end

		  if scale then
					 obj:SetScale ( scale )
		  end

		  obj:SetPosition ( pos )
		  return dObj
end


-- Создает команду машин из списка ListOfVehicle, с именем Name и белонгом Belong, в позиции CreatePos и дает им рандомный товар.
function TeamCreateWithWarez(Name, Belong, CreatePos, ListOfVehicle, WalkPos)
		  return CreateTeam(Name, Belong, CreatePos, ListOfVehicle, WalkPos, 1)
end

function CapturePlayerVehicle(NeedRemove, TeamName, WalkPos)
		  if GetPlayerVehicle() then
					 GetPlayerVehicle():setGodMode(1)
					 local tm
					 if TeamName then
								tm=TeamName
					 else
								tm="PlayerTeam"..random(1000)
					 end

		  local teamID = CreateNewObject{
								prototypeName = "caravanTeam",
										  objName = tm,
										  belong = "1100"
					 }
		  local team=GetEntityByID(teamID)
		  if team then
								GetPlayerVehicle():SetCustomControlEnabled(1)
								team:AddChild(GetPlayerVehicle())
								if WalkPos then
--										println("Walk !!!")
										  team:SetDestination(WalkPos)
								end

								if NeedRemove==1 then
										  team:Remove()
										  return nil
								else
										  return team
					 end
			  end
		  end
end

function ShowCircleOnMinimapByName(objName, mapname, radius)
  local obj=getObj(objName)
  if not obj then
		  return -1
  end

  local map = GET_GLOBAL_OBJECT( "CurrentLevel" ):GetLevelName()
  if mapname then
	  map = mapname
  end

  local rad = 100
  if radius then
	  rad = radius
  end

  local coord = obj:GetPosition()
  ShowCircleOnMinimap( map, CVector(coord), rad )

end

function PlayerDead( ppp )
	 LOG("Player DEAD")
	 println("Player DEAD")
	 local pos = CVector(ppp)
	 local obj = GetEntityByID(CreateNewDummyObject("cub", "", -1, 1100, pos, Quaternion(0.0, 0.0, 0.0, 1.0), 0))
	 if obj==nil then
		  return 
	 end

	 obj:SetDeadTimer( 20000,20000, false )

	 local objid = obj:GetId()
	 pos.y = pos.y + 20
	 pos.z = pos.z + 15
	 FlyAround(5, 0.5, 15, 10, pos, objid, 0, 0, "" ,0 )
	 StartCinematic()
end


--helper function for generating enemies in zone player is currently in
function GenerateEnemiesInPlayerZone()
		  for i = 0, g_ObjCont:size() - 1 do
					 local obj = g_ObjCont:GetEntityByObjId( i )
					 if obj then
								if obj:IsKindOf( "InfectionZone" ) then
										  if obj:IsPlayerInside() then
													 obj:ResetTimeOut()
													 println( "Generated enemies in zone ".. obj:GetName() )
										  end
								end
					 end
		  end
end

function ASSERT( expr , mess)
		  LOG("----------------- TRIGGER ASSERT ------------------------------------------------")
		  if mess then
					 LOG(mess)
					 LOG("---------------------------------------------------------------------------------")
		  end
		  if expr then
					 Assert( expr )
		  else
					 Assert( 0 )
		  end
end




function GenerateRandomAffixList(CountAffixes, ClassAffixes)
		  local listaff1 = {"useless_gun","rusty_gun","excellent_gun","advanced_gun"}
		  local listaff2 = {{"slow_gun","assault_gun","rapid_firing_gun"},{"weak_gun","deadly_gun","destructive_gun"}}
		  local listaff3 = {{"with_truncated_barrel_gun","with_enlarged_barrel_gun","with_long_barrel_gun"},{"without_sight_gun","with_laser_sight_gun","with_electric_sight_gun"},{"without_cooling_gun","with_water_cooling_gun","with_nitro_cooling_gun"}}

		  local listaff = {0}
		  local canused = {1, 1, 1}

		  local TotalClass = 0
		  local claff = 0

		  local affcount=1

		  if CountAffixes~=nil then
					 if CountAffixes>3 then
								affcount=3
		  elseif 0>CountAffixes then
						  affcount=1
					 else
								affcount=CountAffixes
					 end
		  end

		  if ClassAffixes~=nil then
		  claff = ClassAffixes
					 if affcount>claff then
								claff=affcount
					 end
		  end

		  for i=1,affcount do
					 local sub = affcount-i

		  local rndgr
		  repeat 
								rndgr = random (3)
				until canused [rndgr] == 1
			
					 canused [rndgr] = 0

					 if rndgr == 1 then
								local rndnum = random(4)
								if claff>0 then
										  rndnum=4
										  while sub>(claff-rndnum) do		--false!!!
													 rndnum=rndnum-1
										  end
										  claff=claff-rndnum
								end

								listaff[i] = listaff1 [rndnum]
								TotalClass = TotalClass + rndnum
					 elseif rndgr == 2 then
								local rndsubgr = random(2)
								local rndnum = random(3)
								if claff>0 then
										  rndnum=3
										  while sub>(claff-rndnum) do		--false!!!
													 rndnum=rndnum-1
										  end
										  claff=claff-rndnum
								end

								listaff[i] = listaff2 [rndsubgr][rndnum]
								TotalClass = TotalClass + rndnum
					 elseif rndgr == 3 then
								local rndsubgr = random(3)
								local rndnum = random(3)

								if claff>0 then
										  rndnum=3
										  while sub>(claff-rndnum) do		--false!!!
													 rndnum=rndnum-1
										  end
										  claff=claff-rndnum
								end

								listaff[i] = listaff3 [rndsubgr][rndnum]
								TotalClass = TotalClass + rndnum
					 else
								LOG("TRIGGER ERROR: Create Affixes - internal error. Out of range")	  
					 end
		  end

		  return listaff
end


function CreateBoxWithAffixGun(pos, GunPrototype, CountAffixes, ClassAffixes, BoxName)
-- Создает бокс с именем name в позиции pos
-- 
-- 
		  local name = BoxName
		  if name==nil then 
					 name = "ItemsChest"..random(10000)
		  end
		  if pos==nil or GunPrototype==nil then
					 LOG("TRIGGER ERROR: Can't create box or gun. Not position or gun prototype")						  
					 return nil
		  end
		  local afflist = GenerateRandomAffixList ( CountAffixes, ClassAffixes )
		  local chestID = CreateNewObject{		  prototypeName = "someChest",
																										  objName = name
																						 }	 

		  local MyChest=GetEntityByID(chestID)
		  if MyChest==nil then
					 LOG("TRIGGER ERROR: Can't create box ")
					 return nil
		  end
					 
		  MyChest:SetPosition(pos)
		  local id = CreateNewObject{ prototypeName = GunPrototype, objName = "RandomGuns"..random(10000), belong = 1100 }
	 local gun = GetEntityByID( id )

	 if gun==nil then
		 LOG("TRIGGER ERROR: Create Affixes - Can't create gun")
		 return nil
	 end

	 for i=1,getn(afflist) do
					 gun:ApplyAffixByName(afflist[i])
	 end
		  MyChest:AddChild(gun)
end


function AddVehicleGunsWithAffix( ObjName, GunPrototype, ListOfAffixes, GunName)
-- функция генерирует оружие с указаныыми аффиксами и кладет его в инвентарь машины игрока
--		ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--		ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
		  local veh = getObj(ObjName)
	 if GunPrototype==nil or veh==nil then 
		 LOG("TRIGGER ERROR: Create Affixes - No Object Prototype or Object not exists")
		 return nil
	 end


		  local name = GunName

		  if name==nil then 
					 name = "RandomGuns"..random(10000)
		  end

		  local id = CreateNewObject{ prototypeName = GunPrototype, objName = name, belong = 1100 }
	 local gun = GetEntityByID( id )


	 if gun==nil then
		 LOG("TRIGGER ERROR: Create Affixes - Can't create gun")
		 return nil
	 end

	 if ListOfAffixes~=nil then
				if type(ListOfAffixes)=="table" then
								local l=getn(ListOfAffixes)
								for i=1,l do
										  if ListOfAffixes[i] then
													 gun:ApplyAffixByName( ListOfAffixes[i] )
										  end
								end
					 elseif type(ListOfAffixes)=="string" then
								gun:ApplyAffixByName( ListOfAffixes )
					 end
	 end
	 local poloj = veh:AddObjectToRepository(gun)
	 return gun
end



function AddVehicleGunsWithRandomAffix( ObjName, GunPrototype, CountAffixes, ClassAffixes, GunName )
-- Функция для генерации оружия с случайными  аффиксами
-- В CountAffixes - указываеться количество аффиксов (от 1 до 3х)
-- ClassAffixes - уровень (класс) афиксов. Если не указан, то генерируются абсолютно случайные аффиксы
-- если же указан (уровень может быть от 3 до 10), то генерируеться аффиксы в соответствии м указанным уровнем
-- при этом изначально всегда закладываетсья максимальный уровень, оставшиеся распределяеться на что хватает =)
-- т.е. если нужно сгенерировать оружие с 3мя аффиксами и уровнем 6, то первый аффикс будет исметь максимальное значени
-- 3 (или 4 для 1ой группы), оставшиеся 3 (2) поинта сгенерируют 2 аффикса уровня 2(1) и 1 соответственно

		  local res = AddVehicleGunsWithAffix( ObjName, GunPrototype, GenerateRandomAffixList(CountAffixes, ClassAffixes), GunName)
		  return res
end


function AddPlayerGunsWithAffix( GunPrototype, ListOfAffixes, GunName)
-- функция генерирует оружие с указаныыми аффиксами и кладет его в инвентарь машины игрока
--		ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--		ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")

	 local res = AddVehicleGunsWithAffix (GetPlayerVehicle(), GunPrototype, ListOfAffixes, GunName)
		  return res
end



function AddPlayerGunsWithRandomAffix( GunPrototype, CountAffixes, ClassAffixes, GunName )
-- Функция для генерации оружия с случайными  аффиксами
-- В CountAffixes - указываеться количество аффиксов (от 1 до 3х)
-- ClassAffixes - уровень (класс) афиксов. Если не указан, то генерируются абсолютно случайные аффиксы
-- если же указан (уровень может быть от 3 до 10), то генерируеться аффиксы в соответствии м указанным уровнем
-- при этом изначально всегда закладываетсья максимальный уровень, оставшиеся распределяеться на что хватает =)
-- т.е. если нужно сгенерировать оружие с 3мя аффиксами и уровнем 6, то первый аффикс будет исметь максимальное значени
-- 3 (или 4 для 1ой группы), оставшиеся 3 (2) поинта сгенерируют 2 аффикса уровня 2(1) и 1 соответственно
		  AddVehicleGunsWithRandomAffix( GetPlayerVehicle(), GunPrototype, CountAffixes, ClassAffixes, GunName)
--		AddPlayerGunsWithAffix( GunPrototype, GenerateRandomAffixList(CountAffixes, ClassAffixes), ObjName)
end

function AddPlayerGunsWithAffixOrMoney( Money, GunPrototype, ListOfAffixes, GunName)
-- функция генерирует оружие с указаныыми аффиксами и кладет его в инвентарь машины игрока
--		ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--		ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
		  if GetPlayerVehicle():CanPlaceItemsToRepository( GunPrototype, 1 )~=nil then
					 local gun = AddVehicleGunsWithAffix (GetPlayerVehicle(), GunPrototype, ListOfAffixes, GunName)
					 if gun then 
								AddFadingMsgByStrIdFormatted( "fm_player_add_thing", GunPrototype)
					 else
								AddPlayerMoney(Money)
					 end
		  else
					 AddPlayerMoney(Money)
		  end

end

function AddPlayerGunsWithRandomAffixOrMoney( Money, GunPrototype, CountAffixes, ClassAffixes, GunName)
-- функция генерирует оружие с указаныыми аффиксами и кладет его в инвентарь машины игрока
--		ASSERT ( ObjPrototype~=nil, "Create Affix Assert: No Object Prototype ")
--		ASSERT ( GetPlayerVehicle~=nil, "Create Affix Assert: Player Vehicle Not Exists")
		  if GetPlayerVehicle():CanPlaceItemsToRepository( GunPrototype, 1 )~=nil then
					 local gun = AddVehicleGunsWithRandomAffix( GetPlayerVehicle(), GunPrototype, CountAffixes, ClassAffixes, GunName)
					 if gun then 
								AddFadingMsgByStrIdFormatted( "fm_player_add_thing", GunPrototype)
					 else
								AddPlayerMoney(Money)
					 end

		  else
					 AddPlayerMoney(Money)
		  end

end

function exrandom( N )
	 local N2 = N * 2
--	 local aaa=floor(abs( ( random( N2 ) + random( N2 ) + random( N2 ) + random( N2 ) + random( N2 )  ) / 5.0 - N )+1)
	 local aaa=floor(abs( (random( N2 ) + random( N2 ) + random( N2 ) + random( N2 ) + random( N2 )  ) / 5.0 - N )+1)
	 return aaa
end

function RAD( angle )
		  return angle/180*3.14159
end

function EnableGodMode()
		  GetPlayerVehicle():setGodMode(true)
end

function DisableGodMode()
		  GetPlayerVehicle():setGodMode(false)
end

function RotationPlayerByPoints(point2, point1)
		  local player = GetPlayerVehicle()
		  local dir = point1 - point2
		  dir.y = 0
		  player:SetDirection(dir:normalize())
end


function SaveAllToleranceStatus(SetStatus)
	 GL_ToleranceStatus = {}
	 for i=1,200 do
		  GL_ToleranceStatus[i] = {}
		  for j=1,200 do
				GL_ToleranceStatus[i][j] = GetTolerance(i+1000, j+1000)  
		end
	end
	 if SetStatus then 
		  for i=1,200 do
				for j=1,200 do
					 SetTolerance(i+1000, j+1000, SetStatus)
			end
		end
	 end
	
	--apaTche
	local vehPlayer = GetPlayerVehicle()
	MineCharges = vehPlayer:GetPartByName("MINE_PUSHER_SLOT")
	if MineCharges then
		MineChargesPool = MineCharges:GetShellsInPool()
		MineCharges = MineCharges:GetShellsInCurrentCharge()
		vehPlayer:GetPartByName("MINE_PUSHER_SLOT"):SetShellsInCurrentCharge(0)
		vehPlayer:GetPartByName("MINE_PUSHER_SLOT"):SetShellsInPool(0)
	else
		MineCharges = nil
	end
	NitroCharges = vehPlayer:GetPartByName("NITRO_SLOT")
	if NitroCharges then
		NitroChargesPool = NitroCharges:GetShellsInPool()
		NitroCharges = NitroCharges:GetShellsInCurrentCharge()
		vehPlayer:GetPartByName("NITRO_SLOT"):SetShellsInCurrentCharge(0)
		vehPlayer:GetPartByName("NITRO_SLOT"):SetShellsInPool(0)
	else
		NitroCharges = nil
	end
	JumperCharges = vehPlayer:GetPartByName("JUMPER_SLOT")
	if JumperCharges then
		JumperChargesPool = JumperCharges:GetShellsInPool()
		JumperCharges = JumperCharges:GetShellsInCurrentCharge()
		vehPlayer:GetPartByName("JUMPER_SLOT"):SetShellsInCurrentCharge(0)
		vehPlayer:GetPartByName("JUMPER_SLOT"):SetShellsInPool(0)
	else
		JumperCharges = nil
	end
	--apaTche end
end

function RestoreAllToleranceStatus()
		  for i=1,200 do
				for j=1,200 do
					 SetTolerance(i+1000, j+1000, GL_ToleranceStatus[i][j])
				end
		  end
	local vehPlayer = GetPlayerVehicle()
	if vehPlayer then
		vehPlayer:setGodMode( false )
		if Throttle then
		 	vehPlayer:SetThrottle( Throttle )		
	 		Throttle = nil
		end
		if LinearVelocity then 
	 		vehPlayer:SetLinearVelocity( LinearVelocity )
	 		LinearVelocity = nil
		end
		--apaTche
		if MineCharges then 
	 		vehPlayer:GetPartByName("MINE_PUSHER_SLOT"):SetShellsInCurrentCharge(MineCharges)
			vehPlayer:GetPartByName("MINE_PUSHER_SLOT"):SetShellsInPool(MineChargesPool)
			MineCharges = nil
			MineChargesPool = nil
		end
		if NitroCharges then 
	 		vehPlayer:GetPartByName("NITRO_SLOT"):SetShellsInCurrentCharge(NitroCharges)
			vehPlayer:GetPartByName("NITRO_SLOT"):SetShellsInPool(NitroChargesPool)
			NitroCharges = nil
			NitroChargesPool = nil
		end
		if JumperCharges then 
	 		vehPlayer:GetPartByName("JUMPER_SLOT"):SetShellsInCurrentCharge(JumperCharges)
			vehPlayer:GetPartByName("JUMPER_SLOT"):SetShellsInPool(JumperChargesPool)
			JumperCharges = nil
			JumperChargesPool = nil
		end
		--apaTche end
	end

	SaveAfterCin = GetVar( "SaveAfterCin" ).AsString
	CompQuest1 = GetVar( "CompQuest1" ).AsString
	CompQuest2 = GetVar( "CompQuest2" ).AsString
	SetPos = GetVar( "SetPos" ).AsString
	SetRot = GetVar( "SetRot" ).AsString
	RemoveVelocity = GetVar( "RemoveVelocity" ).AsString
	SetVar( "SaveAfterCin", "" )
	SetVar( "CompQuest1", "" )
	SetVar( "CompQuest2", "" )
	SetVar( "SetPos", "" )
	SetVar( "SetRot", "" )
	SetVar( "RemoveVelocity", "" )
	if string.len( SetPos ) > 0 then
		vehPlayer:SetGamePositionOnGround(StringToCVector(SetPos))
	end
	if string.len( SetRot ) > 0 then
		vehPlayer:SetRotation(StringToQuaternion(SetRot))
	end
	if string.len( RemoveVelocity ) > 0 then
		vehPlayer:SetCustomLinearVelocity( 0 )
	end
	if string.len( SaveAfterCin ) > 0 then		 
		SaveGame( SaveAfterCin  )
	end
	if string.len( CompQuest1 ) > 0 then
		CompleteQuest( CompQuest1 )
	end
	if string.len( CompQuest2 ) > 0 then
		CompleteQuest( CompQuest2 )
	end
end

function SetGodTeam (name , godstatus)
	local god=1
	if godstatus then
		god=godstatus
		print(2)
	end
	local teamobj = getObj( name )
	if teamobj then
		local i=0
		while teamobj:GetVehicle(i) do
			print(5)
			teamobj:GetVehicle(i):setGodMode(god)
			i = i + 1
		end
	end
end


function IsLocVisible( loc )
	return IsSphereVisible( loc:GetPosition(), loc:GetRadius() )
end

function netPlay()
		  SetRadarUpgrade(1)
		  Radar:SetScanRadius(500)
		  NetPlay()
end

function CopyTable( t2 )  -- копируем в т1 из т2
		  local t1 = {}
		  for i, v in t2 do
					 if type( v ) == "table" then
								t1[i] = CopyTable( v )
					 else
								t1[i] = v
					 end
		  end
		  return t1
end;

function qua (a)
	return Quaternion(0.0000, sin(a / 2), 0.0000, cos(a / 2))
end

function serialize (o)
  local str = ""
  
  if type(o) == "number" then
		str = str .. tostring( o )
  elseif type(o) == "string" then
		str = str .. string.format("%q", o)
  elseif type(o) == "table" then
		str = str .. "{\n"
		for k,v in pairs(o) do
	  	-- io.write("  ", k, " = ")
		  str = str .. " ["
		  str = str .. serialize( k )
	  	str = str .. "] = "
		  str = str .. serialize(v)
		  str = str .. ",\n"
		end
		str = str .. "}\n"
  elseif type(o) == "boolean" then
		str = str .. tostring( o )
  else
		-- error("cannot serialize a " .. type(o))
		return ""
  end
  
  return str
  --dostring()  --обработать
end

function GetPlayer()
	return GET_GLOBAL_OBJECT "g_Player"
end


-- ==================== --
-- ApaTchE functions --
-- ==================== --

-- function that converts a table into a string
-- useful for storing tables in SetVar variables
-- modo is used for storing tables of strings inside the table
-- modo 1 turns double quotations (") into singular ones (')
-- modo 2 turns double quotations (") into paragraph signs (¶)
-- modo 2 is useful for actually storing tables of strings inside the table in SetVar variables
-- because paragraph signs are automatically converted into single quotation marks by StringToTable
-- and if you use single quotations for that, your dynamicscene will get fucked if you save the game
-- so use modo 2, you have been warned
function TableToString(table, modo)
	local endString = "{"
	local tableLength
	if type(table)=="table" then
		tableLength = getn(table)
		for i=1, tableLength do
			if type(table[i])=="string" then
				if modo==1 then
					endString = endString.."'"..table[i].."'"
				elseif modo==2 then
					endString = endString.."¶"..table[i].."¶"
				else
					endString = endString..'"'..table[i]..'"'
				end
			else
				endString = endString..table[i]
			end

			if i==tableLength then
				endString = endString.."}"
			else
				endString = endString..", "
			end
		end
	else
		endString = '{"idi nahui eto ne massiff)))0)"}'
		println(endString)
	end

	return endString
end

-- function that converts a table presented as string into a real table
-- useful for getting the tables out of SetVar variables
function StringToTable(strVal)
	local endTable = strVal
	endTable = string.gsub(endTable, "¶", "'")
	local funcTableCode = loadstring("local t = "..endTable.."; return t")
	endTable = funcTableCode()

	return endTable
end

-- function that converts a CVector into a string
-- useful for storing CVectors in SetVar variables
function CVectorToString(cvector)
	local endString = "("
	if type(cvector)=="userdata" then
		endString = endString..cvector.x..", "..cvector.y..", "..cvector.z..")"
	else
		endString = "idi nahui eto ne userdata)))0)"
		println(endString)
	end

	return endString
end

-- function that converts a CVector presented as string into a real CVector
-- useful for getting the CVectors out of SetVar variables
function StringToCVector(strVal)
	local endCVector = strVal
	local funcCVectorCode = loadstring("local t = CVector"..endCVector.."; return t")
	endCVector = funcCVectorCode()

	return endCVector
end

-- function that converts a Quaternion into a string
-- useful for storing Quaternions in SetVar variables
function QuaternionToString(quaternion)
	local endString = "("
	if type(quaternion)=="userdata" then
		endString = endString..quaternion.x..", "..quaternion.y..", "..quaternion.z..", "..quaternion.w..")"
	else
		endString = "idi nahui eto ne userdata)))0)"
		println(endString)
	end

	return endString
end

-- function that converts a Quaternion presented as string into a real Quaternion
-- useful for getting the Quaternions out of SetVar variables
function StringToQuaternion(strVal)
	local endQuaternion = strVal
	local funcQuaternionCode = loadstring("local t = Quaternion"..endQuaternion.."; return t")
	endQuaternion = funcQuaternionCode()

	return endQuaternion
end

-- function that allows for an easy fix of trigger duplication caused by GE_TIME_PERIOD timer
-- note that it doesn't prevent the timer itself from duplicating
-- meaning that you might experience severe frame drop if the timers duplicate enough times
-- that is because the trigger will be running this check every time each duplicated timer is triggered
-- (which may be a lot of times, depending on how much times you saved&loaded)
-- you MUST resort to the PendulumVehicle for triggers that have to run at all times (see how it's done in Armada)
--[[ to use this in your trigger with GE_TIME_PERIOD event, put this at the beginning of the trigger:

	if TimerHack(5) then -- arg is the trigger timeout
		return
	end
]]--
-- seconds is the timeout value of your trigger
-- unique_id is the identifier of the timer hack for cases when you use it for multiple GE_TIME_PERIOD triggers at the same time
-- known issues:
-- - the trigger will not go through the first time the timer is triggered, first activation happens at the second timeout
--   (you can fix it by setting the SetVar variable "PreviousTime" to the timeout value of the trigger, before you activate it)
-- - the trigger will always activate at the first timer available (even if it's a duplicated one) after loading the game
--   (this happens because this hack accounts for the real time, and, obviously, some time passes while you're menuing)
function TimerHack(seconds, unique_id)
	local retVal = true
	local currentTime = "etto"..os.time()
	currentTime = string.sub(currentTime, 9)
	local triggerID = ""
	if unique_id then
		triggerID = triggerID..unique_id
	end

	previousTime = GetVar("PreviousTime"..triggerID).AsInt
	-- println("currentTime is "..currentTime..", previousTime is "..previousTime)
	if previousTime <= 0 then
		-- println("previousTime is undefined")
		previousTime = currentTime
		SetVar("PreviousTime"..triggerID, previousTime)
	end

	local timeDifference = currentTime - previousTime
	if seconds >= 10 then
		timeDifference = timeDifference + 1
	end

	-- println("timeDifference is "..timeDifference)
	if seconds <= timeDifference then
		-- println("it's more than "..seconds)
		retVal = false
		SetVar("PreviousTime"..triggerID, currentTime)
	end

	return retVal
end

-- this the first of the three Arcade-specific functions that try to fix the timer on loading the save
-- unfortunately, it breaks the timer numbers coloring as time elapses
-- but the timer works flawlessly on save load, so there's that
-- anyway, this function starts the timer
-- seconds is how long the timer should last
-- trigger is the name of the trigger that has the remaining timer logic and its outcomes
--[[ such a trigger should look something like this:
	
	<trigger	Name="trArcadeTimer"	active="0">
		<event	timeout="5"		eventid="GE_TIME_PERIOD" />
		<script>           
			if TimerHack(5) then -- arg is the trigger timeout
				return
			end

			local timerOutcome = ArcadeTimer(5) -- arg is the trigger timeout
			if timerOutcome==1 then -- if time runs out
				-- your code here
				-- in most cases should contain activation of another trigger
				trigger:Deactivate()
			elseif timerOutcome>=2 then -- if timer is stopped by ArcadeTimerStop()
				-- your code here
				-- in most cases should contain just the trigger:Deactivate() function
				trigger:Deactivate()
			end
		</script>
	</trigger>
]]--
function ArcadeTimerStart(seconds, trigger)
	local timer = 60
	if seconds then
		timer = seconds
	end

	local triggerName = "trArcadeTimer"
	if trigger then
		triggerName = trigger
	end

	HudTimer:Start( timer )
	SetVar("SavedTimerValue", timer)
	TActivate(triggerName)
end

-- function that operates the timer itself, saving the time value and updating the timer
-- requires trArcadeTimer trigger (or any alternative)
-- interval is the timeout (GE_TIME_PERIOD) of the trigger that contains this function
-- returns 0 if the timer continues
-- returns 1 if the time has run out
-- returns 2 if the timer has been stopped
-- this value is used in the trigger to specify the outcome
function ArcadeTimer(interval)
	local timer = GetVar("SavedTimerValue").AsInt
	local retVal = 0
	local timeDifference = 1
	if interval then
		timeDifference = interval
	end

	timer = timer - timeDifference
	if timer < -627627 then
		retVal = 2
	elseif timer < 0 then
		retVal = 1
		timer = 60
	else
		HudTimer:Start( timer )
	end

	SetVar("SavedTimerValue", timer)

	return retVal
end

-- a shortcut function to properly stop the NEW TIMER:tm:
-- pretty much self-explanatory
function ArcadeTimerStop()
	HudTimer:Stop()
	SetVar("SavedTimerValue", -627627)
end

-- function that calculates the total amount of mushrooms on the map
-- tables is the numerical parts of the objects' names in dynamicscene.xml
-- one way to use it is to check from 1 to whatever number you want, like this:
-- ShroomCalc({{1, 20000}})
-- but that is very ineffective and may cause severe lag on execution
-- better check for different ranges of numbers (look into dynamicscene to find out what they are), like this:
-- ShroomCalc({{322, 357}, {627, 1337}, {6969, 8080}, {8841, 9000}})
-- after checking if shrooms with these numbers exist, the function stores the names in a SetVar variable
-- said variable is later used by ShroomRewardCalc
function ShroomCalc(tables)
	local objNamae
	local names = {}
	local amount = 1

	for i=1, getn(tables) do
		for i=tables[i][1], tables[i][2] do
			objNamae = "Breakable_Mushrooms_Explosive"..i
			if getObj(objNamae) then
				names[amount] = objNamae
				amount = amount + 1
			end 
		end
	end
	
	println("there are "..amount.." mushrooms") LOG("there are "..amount.." mushrooms")

	SetVar("Mushrooms", TableToString(names))
end

-- function that calculates the reward for destroying mushrooms;
-- maxR is the maximum possible reward (for destroying all mushrooms);
-- minR is the minimum reward (for destroying 1 mushroom);
-- maxB is the maximum possible bonus reward which scales in geometric progression;
-- the main reward is calculated with the use of arithmetic progression;
-- reach is the amount of reachable mushrooms, used only by geometric progression;
-- if the player destroys this amount of mushrooms, he'll receive a bonus reward;
-- this parameter is completely optional, it's only used in missions in which
-- the player can't realistically destroy all mushrooms present on the map.
function ShroomRewardCalc(maxR, minR, maxB, reach)
	local maxReward = 50; if maxR then maxReward = maxR end
	local minReward = 1; if minR then minReward = minR end
	local maxBonus = 200; if maxB then maxBonus = maxB end
	
	local names = StringToTable(GetVar("Mushrooms").AsString)
	local objNamae
	local shroomsKilled = 0
	local reward = 0

	for i=1, getn(names) do
		objNamae = names[i]
		if not(getObj(objNamae)) then
			shroomsKilled = shroomsKilled + 1
		end 
	end
	
	println("shroomsKilled "..shroomsKilled) LOG("shroomsKilled "..shroomsKilled)

	-- reward calc
	if shroomsKilled~=0 then
		local ratioArithm = maxReward / getn(names)
		local reachable = getn(names); if reach then reachable = reach end
		local ratioGeom = (maxBonus / minReward)^(1/(reachable-1))
--		local completion = shroomsKilled / reach
		reward = (shroomsKilled * ratioArithm) + (minReward * ratioGeom^(shroomsKilled-1))
	end
	
	println("reward "..reward) LOG("reward "..reward)
	return reward
end

-- function that calculates and gives out the reward for destroying mushrooms
-- used at the end of the mission
function ShroomRewardGive(maxReward, minReward, maxBonus, reachable)
	local reward = ShroomRewardCalc(maxReward, minReward, maxBonus, reachable)
	
	AddPlayerMoney(reward)
end

-- function that removes the bonus weapon from player's vehicle
-- requires trRemoveWeapon trigger
-- used at the end of the mission
function BonusWeaponRemove()
	local playa = GetPlayerVehicle()
	local weaponRemover =  getObj("BonusWeaponRemover_mp_rs")
	if playa then
		SetVar("BonusWeaponRemoveSavedPos", CVectorToString(playa:GetPosition()))
		if weaponRemover then
			weaponRemover = weaponRemover:GetPosition()
			weaponRemover.y = weaponRemover.y + 3
			playa:SetPosition(weaponRemover)
		end
	end
	
	TActivate("trRemoveWeapon")
end