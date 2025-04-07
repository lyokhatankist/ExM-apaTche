
function OnAnyRestart()
	RuleConsole( "maxDist 50" )
	SetCameraDist( 50 )

	local vehPlayer = GetPlayerVehicle()
	local Player = GetPlayer()
	if vehPlayer and Player  then
		local k = Player:GetHealth() / Player:GetMaxHealth()
		if k < 0.3 then
			vehPlayer:AddModifier( "hp", "+ "..tostring( Player:GetMaxHealth() * 0.3 ) )
		end
	end
	
--	[M] float GetHealth()   /* returns health of players's vehicle */
--	[M] float GetMaxHealth()   /* returns maximum health of players's vehicle */

end

-- ***************                   ��몠 � ���⠭������ ������                  **********************

function CameraModeTurrelM()
	CameraModeTurrel()
	PlayCustomMusic("CombatBoss1")  
	RuleConsole( "maxDist 4.5" )
	SetCameraDist( 4.5 )
end

function CameraModeWatchM()
	CameraModeWatch()
	PlayCustomMusic("CombatBoss1") 
end


function CameraModeRaceM() 
	StopPlayingCustomMusic()	
	CameraModeRace() 
	RuleConsole( "maxDist 50" )
	SetCameraDist( 50 )
end



-- ***************                   Camera                   **********************

-- apatche
-- i have no idea what original comments say but i've added three new args to the function:
-- setPos - set player position to the specified CVector value after the cutscene (and before the save happens)
-- setRot - set player rotation to the specified Quaternion value after the cutscene (and before the save happens)
-- removeVelocity - set player linear velocity to 0 after the cutscene (and before the save happens)
function FlyShort ( arg )
-- ���� �஫�� ������ ��� ���� ������� ��設��  
-- �ॡ�� �ਣ��� "RestoreTolerance"
-- arg = { 	time = 15   						-- �६� ������, 
-- 					msg = { 2001, 2002 } }  -- �� ��ப
--FlyAround( Phi, Theta, Radius, PlayTime, curPos, Id, StartFade, EndFade, PathName, VisPanel, WaitWhenStop, InterpolateFromPrevious )
--FlyAround( 2, -0.5, 25, 15, GetPlayerVehicle():GetPosition() + CVector( 60 , 50, 60  ), GetPlayerVehicleId(), 1, 1, nil, 1, nil, nil  )	
	local vehPlayer = GetPlayerVehicle()
	if vehPlayer then
		Throttle = vehPlayer:GetThrottle()
		LinearVelocity = vehPlayer:GetLinearVelocity()
	
		vehPlayer:setGodMode( true )
		vehPlayer:SetThrottle( 0 )		
		vehPlayer:SetLinearVelocity( CVector(0,0,0) )

		local a = random( 360 )
		FlyAround( 2, -0.5, 25, arg.time, GetPlayerVehicle():GetPosition() + CVector( 60 * sin(a), 85, 60 * cos(a) ), GetPlayerVehicleId(), 0, 0, nil, 1, nil, nil  )	
		StartCinematic()
		
		local t = 1
		for i, v in arg.msg do			
			AddCinematicMessage( v, t )
			t = 0.25
		end
	end
	SaveAllToleranceStatus( RS_NEUTRAL )
	TActivate( "RestoreTolerance" )
	-- apaTche
	if arg.setPos then
		SetVar( "SetPos", CVectorToString(arg.setPos) )
	end
	if arg.setRot then
		SetVar( "SetRot", QuaternionToString(arg.setRot) )
	end
	if arg.removeVelocity then
		local xD = arg.removeVelocity
		SetVar( "RemoveVelocity", ""..xD.."" )
	end
	if arg.removeWeapon then
		BonusWeaponRemove()
	end
	-- apaTche end
	if arg.saveMap then
		SetVar( "SaveAfterCin", arg.saveMap )
	end
	if arg.CompQuest1 then
		SetVar( "CompQuest1", arg.CompQuest1 )
	end
	if arg.CompQuest2 then
		SetVar( "CompQuest2", arg.CompQuest2 )
	end
end

-- ***************                   Compas           **********************
--   ��⥬� �㭪権 ��뢠���� �� �ਣ��஢ ��� ������樨 ��設�   
--   �������� �����뢠�� �㤠 ���� �����쭮, ��� ���⨦���� ������쭮� �窨 ���, 
--   �� ����稨 ��� �吝��⨩ �� ���祢�� ����権 �����
--   ⨯� �� ��������� � ���祢�� ��� ᬮ�ਬ � �㤠 �� ��� ���� � ��� �� �窠 �㤠 �� ������... 
--   ���� � �ਭ� �� ����.

--   ***   ��� ࠡ��� �ॡ���� ⠡��� Nav   ***


function CompasCore( trigger )
 	trigger:Deactivate()
	local tr_Start = getObj( "trNavWork" )
			
  for i,v in Nav.Points do
		tr_Start:AddEvent	( "GE_OBJECT_ENTERS_LOCATION", v.Point ) 	
	end;      

	tr_Start:Activate()
	getObj( "NavDraw" ):Activate()
end


function CompasWork( trigger )
	local loc = trigger:GetCallObjName() 
	local cur_p_ID = nil
	Nav.LastKnow = Nav.Next_way_point
	Nav.Next_way_point = nil

  for i,v in Nav.Points do 
  	if v.Point == loc then
  		cur_p_ID = i
			break
  	end
  end        		

  if cur_p_ID == Nav.Destination then
		Nav.Next_way_point = cur_p_ID
  else
		local old = {}
		local ways = {}

	  local cur_w = { cur_p_ID }
	  table.insert( ways, cur_w )
	  local is_Find = false
	  local find_Way = nil

		while not( find_Way ) and ( table.getn( ways ) > 0 ) do
			local new_ways = {}
			for i, v in ways do
				local n = table.getn( v )
				local l_ID = v[ n ]
				for j, k in Nav.Points[ l_ID ].Connected do
					local k_in_old = false --ᬮ�ਬ �� �뫨 �� � �⮩ �窥
					for l, m in old do
						if m == k then k_in_old = true end
					end

					if  Nav.Points[ l_ID ].isPrimary > Nav.Points[k].isPrimary then --ᬮ�ਬ ����� �� �㤠 �� �ਮ����
						k_in_old = true
					end

					if not( k_in_old ) then
						table.insert( old, k )
						local tt = CopyTable( v )
						table.insert( tt, k )
						table.insert( new_ways, tt )

						if k == Nav.Destination then 
							find_Way = tt
						end
					end -- ����� �᫨ �窠 �� ���饭�					
				end 	-- ����� ��室� ��� �祪 �� ���� ⥪�饩
			end			-- ����� ��室� ��� ��⥩
			ways = new_ways
		end				-- ᫥��騩 �஢��� �����

		if find_Way then
    	if table.getn( find_Way ) > 1 then 
				Nav.Next_way_point = find_Way[2]
			end
		end
	end
	if not Nav.Next_way_point then
		Nav.Next_way_point = Nav.LastKnow
	end
end


function CompasShow( trigger )
--[[ �ᮢ���� �㤠 ����            �㭪�� ���� �⪫����, ����� ���  GetNavpointPos() ��뢠���� �� ����
	if Nav.Next_way_point then
		local l = getObj( Nav.Points[ Nav.Next_way_point ].Point )
		local v = GetPlayerVehicle()
		if l and v then		
			local pos = v:GetPosition() + 22 * ( l:GetPosition() - v:GetPosition()   ):normalize() +CVector( 0, 3, 0 )
			local  compas = getObj( CompasId )
			if not( compas ) then
				CompasId = CreateNewSgNodeObject( "ET_PS_BLINK", "compas", -1, 1101, pos )
				compas = getObj( CompasId )
			end
			if compas then
				compas:SetPosition( pos )
			end
		end
	end
	]]
end


function GetNavpointPos()
  local pos = nil
	if Nav then
		if not Nav.off then
			if Nav.Next_way_point then
				local l = getObj( Nav.Points[ Nav.Next_way_point ].Point )
				if l then
					pos = l:GetPosition()
		 		else
--		 			LOG("Compas: Navigation point not found")
				end				
			else
--				LOG("Compas: Nav.Next_way_point not found")
			end
		end
	else
--		LOG("Compas: Navigation table not found")
	end
	return pos
end


function CompasOff()
	getObj( "NavDraw" ):Deactivate()	
	getObj( "trNavWork"	):Deactivate()	
	--TODO ������� ����䥩�� �� �ᮢ��� ������
	Nav.off = true
end                              


function CompasOn( Dest, NextWay_ )
	local NextWay = NextWay_ or Nav.Next_way_point
	getObj( "NavDraw" ):Activate()	
	getObj( "trNavWork"	):Activate()	
	if Dest and  NextWay then
		Nav.Next_way_point = NextWay
		Nav.Destination    = Dest
	end
	--TODO ������� ����䥩�� �ᮢ��� ������
	Nav.off = false
end





-- ***************                   Ambush                   **********************
-- ��ᠤ� �����, ��饭� ������� �ࠣ��.
--   ***   ��� ࠡ��� �ॡ���� ⠡���    Ambushs  ***

function AmbushInit(  trigger  )
	local tr_Start = getObj("trAmbStart")
			
  for i,v in Ambushs do
		tr_Start:AddEvent	( "GE_OBJECT_ENTERS_LOCATION", v.onEnter ) 	
	end;      

	tr_Start:Activate()	
end


function AmbushWork(  trigger  )
	local loc = trigger:GetCallObjName() 
	trigger:DelEventObj( "GE_OBJECT_ENTERS_LOCATION", loc )

	local amb = nil
	for i,v in Ambushs do
		if v.onEnter == loc then 
			amb = v 
			break
		end
	end

	local belong = amb.belong or (1110 + math.random(4))

	CreateTeam( "ambTeam_"..amb.onEnter , belong, getPos( amb.onSpawn ), amb.spawnTeam, getPos( loc ))
end




-- ***************                   ��릮� - �����                   **********************
-- �ॡ�� ����� �ਣ��஢ (� ����2) + CamJump ⠡����
function CamJumpInit(  trigger  )
	local tr_Start 	= getObj("trCamJump")
	local tr_End 		= getObj("trCamJumpOut")			
  for i,v in CamJump do
		tr_Start:AddEvent	( "GE_OBJECT_ENTERS_LOCATION", v.onEnter ) 	
		tr_End:AddEvent		( "GE_OBJECT_LEAVES_LOCATION", v.onEnter ) 	
	end;      
	tr_Start:Activate()
	tr_End:Activate()
end


function CamJumpWork( trigger )
	local loc = trigger:GetCallObjName() 		

	local amb = nil
	for i,v in CamJump do
		if v.onEnter == loc then 
			amb = v 
			break
		end
	end

	if amb.OneTime then
		trigger:DelEventObj( "GE_OBJECT_ENTERS_LOCATION", loc )
	end

	local v = GetPlayerVehicle()
	if v then
		local ll = v:GetLinearVelocity( ):length()
		local vv = getPos( v ) 
--LOG( "JUMP: "..tostring( vv.y ).."   :   "..tostring( ll ) )
		if ll > amb.Speed and vv.y > amb.Height then
		  CameraModeWatch()
			SetCameraPosFrom( CVector( amb.cam.x, amb.cam.y, amb.cam.z ), getPos( amb.onEnter ) )
			TActivate("trCamJumpOutTime")
		end
	end
end



-- ***************                   Save | Load                   **********************
-- �㭪樨 �� �⥭�� ������ - ����⮭�������� ⠡���� � ����묨 
-- todo ������� � ��⠢��� 
function saveMap()
end
function loadMap()
end




-- ***************                   �⫠���                   **********************

function trToxicGo(trigger)
	local triggerTime 			= 1		-- ᪮�쪮 ࠧ � ᥪ ࠡ�⠥� ��� �ਣ��� (� ������)
	local step 							= 22  -- 蠣 �⪨ ��䥪⮢/������
	local widthTox					= 8		-- �ਭ� �⪨ 鸞 ( *2 * step)

	local skipEffVertical 	= 3   -- ��� ��� �ய�᪠�� ࠧ � 蠣 ����� ��������
	local skipEffHorisontal = 6  	-- ��� ��� �ய�᪠�� ࠧ � 蠪 ����४ ��������
	local effForvard 				= 40 	-- �뭮� �ᮢ���� ��䥪� ���।
	local effHiStop					= 22	-- ���� � ���ன ��䥪� � ���� �� ������
	local randomShift				= 5

	local accelIfFar 	= 5		-- ����業� �᪮७��
	local accelLength	= 160  -- ���쭮��� � ���ன �⠪� �᪮����� 
--LOG( "  0" )
	if toxic[ curPoint ] and toxic[ curPoint + 1 ] then
		local curLoc = getObj( toxic[ curPoint ].Point )
		local nextLoc = getObj( toxic[ curPoint + 1 ].Point )
--LOG( "  1" )
		if nextLoc and curLoc then
			local v = GetPlayerVehicle()
			local v_pos = CVector( 0, 0, 0 ) 
			if v then		
				v_pos = v:GetPosition()
			end 
--LOG( "  2" )
			local curVec = ( nextLoc:GetPosition() - curLoc:GetPosition() ):normalize()
			local curPos = curLoc:GetPosition()

			local localLength = curSpeed 	* triggerTime		
			if ( ( curPos + curVec * curLength ) - v_pos ):length() > accelLength then
				localLength = localLength * accelIfFar
			end
			curLength 				= curLength + localLength
			local aspectPoint = curPos + curVec * curLength
--LOG( "  3" )
			local crossVect 	= curVec:cross( CVector( 0, 1, 0 ) ) 
--LOG( "  31" )
			for j = 0, 5 do
--LOG( "  32" )
				local locAspectPoint = aspectPoint - curVec * j * step
--LOG( "  33" )
				local rr = skipEffHorisontal
--LOG( "  34" )
				for i = -widthTox, widthTox do 
--LOG( "  35" )
					local pp = locAspectPoint + crossVect * i * step + CVector( random( randomShift * 2 ) - randomShift, 7, random( randomShift * 2 ) - randomShift )
--LOG( "  36" )
					local ppy = pp.y

--LOG( "  37: "..tostring(pp.x)..":"..tostring(pp.z) )

					pp.y = GetHeight( pp.x, pp.z )
--LOG( "  38" )
					local hiBit = true
--LOG( "  39" )
					if   abs( ppy - pp.y ) > effHiStop then hiBit = false end
--LOG( "  4" )
				  local bw = CreateNewObject( { prototypeName = "ToxicBoss_"..tostring(j), objName = "tempwave" } ) 	  
				  getObj( bw ):SetPosition( pp )
				  if 	( j == 0 ) and  hiBit and
				  		( (( random( skipEffVertical ) == 1 ) and ( random( rr ) == 1 )) 
				  		or ( 1 == abs(i) ) ) then
					  CreateEffectTTLed( "ET_PS_GREEN_SMOKE1", pp + curVec * effForvard, Quaternion(0.0000, 0.0000, 0.0000, 1.0000), 0.5 * 24000 )
-- ���					  CreateEffectTTLed( "ET_PS_BLINK", pp + curVec * effForvard, Quaternion(0.0000, 0.0000, 0.0000, 1.0000), 0.5 * 24000 )					  
					  if 3 > rr then rr = rr + skipEffHorisontal end
					end
					if rr > 1 then rr = rr - 1 end 
				end
			end
--LOG( "  5" )		
			if curLength > ( nextLoc:GetPosition() - curLoc:GetPosition() ):length() then 
				curLength = 0
				curPoint 	= curPoint + 1
			end
		end
	else
		trigger:Deactivate()
		if ( getObj("trBossToxicGate"):IsActivated() == 0 ) then
--			TActivate( "trInitFightBoss" ) �ࣥ��, ������ ���?
			TActivate("trToxiInit")
			TActivate("trToxicity")
			p("trPreInitFightBoss 3")
		end
	end
end