--[=[
	[[open source code]]
	Itz_xseawxs3e83 purple shader
	Original pshade by @Im_patrick. This version modified with a purple theme.
	
	pshade is made by content creator on youtube called @Im_patrick feel free to subs
	
	some code might be obfuscated for privacy or security reason (example : feedback)
	this is not mean to be edited/stolen
	
	This script is still in beta stage so make sure to use the loadstring so it can always be updated
	
	https://randomstring0.github.io/pshade.github.io/
]=]

if _G.pshade_itz_xseawxs3e83 then return warn"Itz_xseawxs3e83 purple shader already loaded!" end -- Ensure unique global flag
if not game then local game=Workspace['Parent'] end
if not game:IsLoaded() then game["Loaded"]:Wait() end

local update = [=[
	> MODIFIED: Purple Theme by Itz_xseawxs3e83
	> fixed blur effect
	> added adjust auto load and fix ui size
	> small update for gui
	> fixed some features not showing up
	> faster preview
	> lighting element cannot be deleted fix
	> night theme
	> small fix and error handle 
	> small debug update
	> more games support
	> skybox added
	> filesystem fix
	> slow load fix
	> more adjustment stuff
	> new ui and old ui combination
	> gui dragging fix
	> shader load faster
]=]

_G.pshade_itz_xseawxs3e83=true -- Unique global flag
_G.vers="1.4.8_purple_v1" -- Modified version
local light

local game=game
local xpcall=xpcall
local type=type
local next=next
local pcall=pcall
local typeof=typeof

local mrandom,schar, mfloor,mhuge=math['random'],string['char'],math['floor'],math['huge']
local mfloor,mceil=math['floor'],math['ceil']
local twait,tspawn=task['wait'], task['spawn']
local mclam,mround=math['clamp'],math['round']
local mcos,msin,mtan=math['cos'],math['sin'],math['tan']
local mabs,mdeg,mrad=math['abs'],math['deg'],math['rad']
local msqrt=math['sqrt']
local di=debug['info']

local findclass=game["FindFirstChildOfClass"]
local getchild=game["GetChildren"]
local clone=game["Clone"]
local destroy=game["Destroy"]
local find=game['FindFirstChild']
local isa=game["IsA"]

local ins=Instance['new']
local ws=findclass(game,'Workspace')
local cam=find(ws,"Camera")
local lg=findclass(game,"Lighting")
local terr=findclass(ws,"Terrain")
local uis=findclass(game,"UserInputService")
local tweenSvc=findclass(game,"TweenService") -- Renamed to avoid conflict with local tween function
local http=findclass(game,"HttpService")
local market=findclass(game,"MarketplaceService")
local rs=findclass(game,"RunService")
local plrs=findclass(game,"Players")
local lp=plrs['LocalPlayer']
local pg=lp['PlayerGui']
local mouse=lp:GetMouse()
local sett1=nil
local fenv=getfenv()
local shp=fenv['sethiddenproperty'] or fenv['sethiddenprop'] or fenv['set_hidden_property'] or fenv['set_hidden_prop'] or function() return end
local ghp=fenv['gethiddenproperty'] or fenv['gethiddenprop'] or function() return end
local httpget=function(a) return loadstring(game:HttpGet(a))() end --fenv['HttpGet']
local read,write,file=fenv['readfile'],fenv['writefile'],fenv['isfile']
local setclip=fenv['setclipboard'] or function() return end
local fdist,fsize,ftrans={1.7,0.3,-0.3,-0.9},{0.7,0.2,1.2,0.45},{0.8,0.7,0.9,0.6}
local fls,sre,sflare,rmod={},ins('ScreenGui',pg),ins('ImageLabel'),1
local bmut,ber,lor=11,5,cam['CFrame']['LookVector']
local colorcor,atmosphere,bloom,blur,depth,sky,sray,cloud
local randomstring='https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/'
local technology=ghp(lg,'Technology') or 'ShadowMap'
local lan=httpget(randomstring..'lan/every.json')
local randomsky=randomstring..'sky/'
if rs:IsStudio() then return end
local src=randomstring..'src/'
local flare,motionblur
local wshade=true
local thick = tick()
local restore={}
local shader={}
local skybox={}
local new={}
local wl={}
shader.__index=shader

local sc=httpget(src..'ui')
local image=sc["mainmage"]
local main=image["main"]
local addfr=main["addtionframe"]['Frame']
local mbar=main["mainbar"]['Frame']
local mpage=main['mainpage']

local prop=main["propperty sample"]
local ntf=sc['notif']
local icon=sc['icon']

local click=sc['click']
local clicking=sc['clicking']

-- THEME COLOR: Changed to a purple shade
local color=sc['colorvalue']
color.Value = Color3.fromRGB(138, 43, 226) -- BlueViolet, a nice purple

local intro=sc['intro']

local intext=intro['main']['TextLabel']
local title=mbar['Frame']['maintitle']
local barfunc=mbar['functionbar']

local page=mpage['page']['Frame']
local spage=mpage['showpage']

local shadertog=addfr['toggleshaderframe']
local togd=shadertog['handle']
local home=spage['home']
local changelog=home['ScrollingFrame']['changelog']

-- THEME NAME: Changed to "Purple Shader XE" (hex: 507572706c6520536861646572205845)
local xddcc="507572706c6520536861646572205845" 
coroutine['wrap'](function() httpget(src..'check.lua') end)()
-- local shader -- already defined above
local check=true
shp(lg,'Technology',"ShadowMap")

local adjust={
	['reflect']=nil,
	['waterspeed']=nil,
}

local tween=function(i,p,d)
	local d=d or 1
	-- Ensure TweenService is used correctly
	return tweenSvc:Create(i,TweenInfo['new'](d,Enum['EasingStyle']['Exponential'],Enum['EasingDirection']['Out']),p):Play()
end

local drag=function(n,s)
	local dr,di,ds,sp=false,nil,Vector3['new'](0,0,0),nil
	local move=function(i)
		local d=i['Position']-ds
		local p=UDim2['new'](sp['X']['Scale'],sp['X']['Offset']+d['X'],sp['Y']['Scale'],sp['Y']['Offset']+d['Y'])
		tween(s,{Position=p},.15)
	end

	n['InputBegan']:Connect(function(i)
		if i['UserInputType'] == Enum['UserInputType']['MouseButton1'] or i['UserInputType'] == Enum['UserInputType']['Touch'] then
			dr,ds,sp=true,i['Position'],s['Position']
			i['Changed']:Connect(function()
				if i['UserInputState'] == Enum['UserInputState']['End'] then
					dr=false
				end
			end)
		end
	end)

	n['InputChanged']:Connect(function(i)
		if i['UserInputType'] == Enum['UserInputType']['MouseMovement'] or i['UserInputType'] == Enum['UserInputType']['Touch'] then
			di=i
		end
	end)

	uis['InputChanged']:Connect(function(i)
		if i==di and dr then
			move(i)
		end
	end)
end

local notif=function(t,d)
	coroutine['wrap'](function()
		local n=clone(ntf)
		n['Parent']=sc
		n['Image']=image['Image'] -- Consider theming notification background if possible
		n['title']['Text']=t
		n['Visible']=true
		n['Size']=UDim2['new'](0,0,0,0)
		tween(n,{Size=UDim2['new'](0.512,0,0.118,0)},.3)
		twait(d or 3)
		tween(n,{Position=UDim2['new'](0.5,0,0,-30)},.5)
		twait(.5)
		n:Destroy()
	end)()
end

local fh=function(s)
	return (s:gsub('..', function(c)
		return schar(tonumber(c, 16))
	end))
end

local random=function(l)
	local s=""
	local l=l or 5
	for i=1,l do
		local n=mrandom(1,3)
		if n==1 then
			s=s..schar(mrandom(65,90))
		elseif n==2 then
			s=s..schar(mrandom(97,122))
		else
			s=s..tostring(mrandom(0,9))
		end
	end
	return s
end

local bestname=random()
coroutine['wrap'](function()
if findclass(lg,"BloomEffect") then
	findclass(lg,"BloomEffect")['Enabled']=false
	local b=clone(findclass(lg,"BloomEffect"))
	b['Parent']=lg
	b['Enabled']=true
	bloom=b
	table['insert'](restore,b)
	table['insert'](new,bloom)
end
if findclass(lg,"Sky") then
	local b=clone(findclass(lg,"Sky"))
	b['Parent']=lg
	sky=b
	table['insert'](restore,b)
	table['insert'](new,sky)
end
if findclass(lg,"Atmosphere") then
	local b=clone(findclass(lg,"Atmosphere"))
	b['Parent']=lg
	atmosphere=b
	table['insert'](restore,b)
	table['insert'](new,atmosphere) -- Fixed: was 'new,sky'
end
if findclass(lg,"BlurEffect") then
	findclass(lg,"BlurEffect")['Size']=0
	local b=clone(findclass(lg,"BlurEffect"))
	b['Parent']=lg
	b['Enabled']=true
	blur=b
	table['insert'](restore,b)
	table['insert'](new,blur) -- Fixed: was 'new,sky'
end
if findclass(lg,"DepthOfFieldEffect") then
	findclass(lg,"DepthOfFieldEffect")['Enabled']=false
	local b=clone(findclass(lg,"DepthOfFieldEffect"))
	b['Parent']=lg
	b['Enabled']=true
	depth=b
	table['insert'](restore,b)
	table['insert'](new,depth) -- Fixed: was 'new,sky'
end
if findclass(lg,"ColorCorrectionEffect") then
	findclass(lg,"ColorCorrectionEffect")['Enabled']=false
	local b=clone(findclass(lg,"ColorCorrectionEffect"))
	b['Parent']=lg
	b['Enabled']=true
	colorcor=b
	table['insert'](restore,b)
	table['insert'](new,colorcor) -- Fixed: was 'new,sky'
end
if findclass(lg,"SunRaysEffect") then
	findclass(lg,"SunRaysEffect")['Enabled']=false
	local b=clone(findclass(lg,"SunRaysEffect"))
	b['Parent']=lg
	b['Enabled']=true
	sray=b
	table['insert'](restore,b)
	table['insert'](new,sray) -- Fixed: was 'new,sky'
end

	if findclass(terr,"Clouds") then
		local existing_cloud = findclass(terr,"Clouds") -- Added this line to define existing_cloud
		local b = clone(existing_cloud) -- Clone the existing cloud
		b.Parent = terr -- Parent it to terrain
		cloud=b -- Assign to global cloud variable
		table['insert'](restore,b)
		table['insert'](new,cloud)
	end


	if not colorcor then
		colorcor=ins('ColorCorrectionEffect')
		colorcor['Parent']=lg
		table['insert'](new,colorcor)
	end
	if not atmosphere then
		atmosphere=ins('Atmosphere')
		atmosphere['Parent']=lg
		atmosphere['Density']=0
		table['insert'](new,atmosphere)
	end
	if not bloom then
		bloom=ins('BloomEffect')
		bloom['Parent']=lg
		table['insert'](new,bloom)
	end
	if not blur then
		blur=ins('BlurEffect')
		blur['Parent']=lg
		blur['Size']=0
		table['insert'](new,blur)
	end
	if not depth then
		depth=ins('DepthOfFieldEffect')
		depth['Parent']=lg
		table['insert'](new,depth)
	end
	if not sky then
		sky=ins('Sky')
		sky['Parent']=lg
		table['insert'](new,sky)
	end
	if not sray then
		sray=ins('SunRaysEffect')
		sray['Parent']=lg
		table['insert'](new,sray)
	end
	if not cloud then
		cloud=ins('Clouds')
		cloud['Parent']=terr
		cloud['Cover']=0
		cloud['Density']=0
		table['insert'](new,cloud)
	end

	terr['ChildRemoved']:Connect(function(a)
		if a['Name']==bestname then
			local v=clone(a)
			v['Parent']=terr
			if isa(a,"Clouds") then
				cloud=v
			end
		end
	end)

	lg['ChildRemoved']:Connect(function(a)
		if a['Name']==bestname then
			local v=clone(a)
			v['Parent']=lg
			if not isa(v,"Sky") and not isa(v,"Atmosphere") then
				table['insert'](restore,v)
			end
			if isa(v,"BloomEffect") then
				bloom=v
			elseif isa(v,"Sky") then
				sky=v
			elseif isa(v,"Atmosphere") then
				atmosphere=v
			elseif isa(v,"BlurEffect") then
				blur=v
			elseif isa(v,"DepthOfFieldEffect") then
				depth=v
			elseif isa(v,"ColorCorrectionEffect") then
				colorcor=v
			elseif isa(v,"SunRaysEffect") then
				sray=v
			end
		end
	end)
	
	for _,v in ipairs(restore) do
		v['Name']=bestname
	end
	for _,v in ipairs(new) do
		v['Name']=bestname
	end

	local ch=httpget(src..'blacklst.json')
	local noall=false
	local userId = lp.UserId -- Define userId

	for _, entry in ipairs(ch) do
 	  if entry['id'] == userId then
   	       noall = true
			write('.n', entry['reason'])
			coroutine['wrap'](function() lp:Kick('blacklisted, reason : ' .. entry['reason']) end)()
			twait(.7) -- task.wait instead of wait
			lp:Destroy()
			game:Shutdown()
   	     break
   	  end
	end
end)()

local backup={
	['lighting']={
		['ClockTime']=lg['ClockTime'],
		['Ambient']=lg['Ambient'],
		['Brightness']=lg['Brightness'],
		['ColorShift_Bottom']=lg['ColorShift_Bottom'],
		['ColorShift_Top']=lg['ColorShift_Top'],
		['EnvironmentDiffuseScale']=lg['EnvironmentDiffuseScale'],
		['EnvironmentSpecularScale']=lg['EnvironmentSpecularScale'],
		['GlobalShadows']=lg['GlobalShadows'],
		['OutdoorAmbient']=lg['OutdoorAmbient'],
		['ShadowSoftness']=lg['ShadowSoftness'],
		['technology']=technology,
		['GeographicLatitude']=lg['GeographicLatitude'],
		['ExposureCompensation']=lg['ExposureCompensation'],
		['FogEnd']=lg['FogEnd'],
		['FogColor']=lg['FogColor'],
		['FogStart']=lg['FogStart']
	},
	['terrain']={
		['WaterColor']=terr['WaterColor'],
		['WaterReflectance']=terr['WaterReflectance'],
		['WaterTransparency']=terr['WaterTransparency'],
		['WaterWaveSize']=terr['WaterWaveSize'],
		['WaterWaveSpeed']=terr['WaterWaveSpeed']
	}
}

local default={ -- THEME: Consider if default shader values should have a purple hint or remain neutral
	['yfbghj']=lg['Ambient'], 
	['tgvbyd']=lg['ClockTime'], 
	['ghuybhuyhj']=lg['GeographicLatitude'], 
	['khnbfth']=lg['Brightness'],
	['hgyghkg']=lg['ColorShift_Bottom'],
	['yfbhjku']=lg['ColorShift_Top'], 
	['ygyyfgvhbjytrt']=lg['EnvironmentDiffuseScale'],
	['sdfcddc']=lg['EnvironmentSpecularScale'],
	['hgnujuu7thgr']=lg['GlobalShadows'],
	['hyhnngtf']=lg['OutdoorAmbient'],
	['hdfr7thgr']=lg['ExposureCompensation'],
	
	['fhnchvhfjsd']=colorcor['Brightness'],
	['ugtbbjhygt']=colorcor['Contrast'],
	['tfbghuugbnjhg']=colorcor['Saturation'],
	['fvrtccvghghj']=colorcor['TintColor'], -- Could be a place for a subtle default purple tint if desired

	['jnfdhbnfcvh']=bloom['Intensity'],
	['fvtyghj']=bloom['Size'],
	['ygbhnj']=bloom['Threshold'],

	['njnfg']=blur['Size'],
	['jdfkd']=depth['FarIntensity'],
	['fvgsdfg']=depth['FocusDistance'],
	['sdkvkflv']=depth['InFocusRadius'],
	['hbjhd']=depth['NearIntensity'],

	['gyhgtg']=cloud['Cover'],
	['ygbhggv']=cloud['Density'],
	['jghbjhgyfd']=cloud['Color'],

	['shdbsnjfc']=atmosphere['Density'],
	['skdjfkdm']=atmosphere['Offset'],
	['sjdjncdjf']=atmosphere['Color'], -- Atmosphere color could also be themed
	['efjdjfk']=atmosphere['Decay'],
	['sejfd']=atmosphere['Glare'],
	['jddfjsd']=atmosphere['Haze']
}

light = default

local con=function(a,c,b) a[b or 'MouseButton1Click']:Connect(c) end

local function toHex(v) if type(v)=="number" then return v%1==0 and string.format("0x%X",v) or tostring(v) elseif type(v)=="string" then local h={} for i=1,#v do table.insert(h,string.format("\\x%02X",v:byte(i))) end return "\"" .. table.concat(h) .. "\"" else return tostring(v) end end
local function serializeTable(t,i) i=i or 0 local s=string.rep(" ",i) local r="{\n" for k,v in pairs(t) do local kf=type(k)=="string" and "[\""..k.."\"]" or "["..k.."]" local vf=typeof(v)=="Color3" and string.format("Color3.new(%g, %g, %g)",v.R,v.G,v.B) or (type(v)=="table" and serializeTable(v,i+1) or toHex(v)) r=r..s.." "..kf.."="..vf..",\n" end return r..s.."}" end

local function fromHexNumber(v) return tonumber(v,16) or v end
local function fromHexString(v) return v:gsub("\\x(%x%x)",function(h) return string.char(tonumber(h,16)) end) end
local function deserializeTable(t) local function fix(x) for k,v in pairs(x) do if type(v)=="string" then if v:match("^0x[%x]+$") then x[k]=tonumber(v,16) elseif v:match("\\x[%x][%x]") then x[k]=v:gsub("\\x(%x%x)",function(h) return string.char(tonumber(h,16)) end) end elseif type(v)=="table" then fix(v) end end return x end return fix(t) end

local snap=function(v,s)
	return mfloor(v/s+0.5)*s
end

local findsearch=function(t,i,c)
	local t=t:lower()
	local c=c or "Frame"
	if t~="" then
		for _,v in pairs(i:GetChildren()) do
			if isa(v,c) then
				if v['Name']~="sample" then
					local current_v=v -- Renamed to avoid conflict
					if current_v['Name']:lower():sub(1,#t)==t then
						current_v['Visible']=true
					else
						current_v['Visible']=false
					end
				end
			end
		end
	else
		for _,v in pairs(i:GetChildren()) do
			if isa(v,c) then
				if v['Name']~="sample"then
					v['Visible']=true
				end
			end
		end
	end
end

local ob=function(u)
	return ws:FindPartOnRay(Ray['new'](cam['CFrame']['Position'],lg:GetSunDirection()*900),u)~=nil
end

local getsun=function()
	local camscreen=cam:WorldToScreenPoint(cam['CFrame']['Position']+lg:GetSunDirection())
	return Vector2['new'](camscreen['X'],camscreen['Y']),camscreen['Z']>0
end

local camcenter=function()
	return cam['ViewportSize']/2
end

local mblur_effect=ins("BlurEffect",cam) -- Renamed to avoid conflict
mblur_effect['Size']=0

ws['Changed']:Connect(function(p)
	if wl['mblur'] and p=="CurrentCamera" then
		mblur_effect['Size']=bmsize
	end
end)

local absw=false
local abs_animate=function(c,w) -- Renamed 'abs' to 'abs_animate'
	local w=w or .2
	coroutine['wrap'](function()
		if absw then return end
		absw=true
		for _,v_item in ipairs(c:GetDescendants()) do -- Renamed 'v' to 'v_item'
			if isa(v_item,"GuiObject") then
				local old={
					pos=v_item['Position'],
					size=v_item['Size'],
					rot=v_item['Rotation'],
					trans=v_item['BackgroundTransparency']
				}
				v_item['Position']=UDim2['new'](mrandom(),0,mrandom(),0)
				v_item['Size']=UDim2['new'](0,0,0,0)
				v_item['BackgroundTransparency']=1
				tween(v_item,{Position=old['pos'],Size=old['size'],Rotation=old['rot'],BackgroundTransparency=old['trans']},w)
			end
		end
		absw=false
	end)()
end

wl={
	['dof']=true,
	['cor']=true,
	['sray']=false,
	['bl']=true,
	['blr']=false,
	['rays']=false,
	['sflare']=false,
	['mblur']=false,
	['tech']="ShadowMap"
}

local defsky={
	['bk']=sky['SkyboxBk'],
	['dn']=sky['SkyboxDn'],
	['ft']=sky['SkyboxFt'],
	['lt']=sky['SkyboxLf'],
	['rt']=sky['SkyboxRt'],
	['up']=sky['SkyboxUp']
}

local cussky={ -- THEME: Consider if default custom skybox should have purple elements
	['bk']='rbxassetid://9544505500',
	['dn']='rbxassetid://9544547905',
	['ft']='rbxassetid://9544504852',
	['lt']='rbxassetid://9544547694',
	['rt']='rbxassetid://9544547542',
	['up']='rbxassetid://9544547398'
}

coroutine['wrap'](function()
	local ss,fl=pcall(function() sett1=settings() end)
	if not ss then
		sett1={}
	end
	
	skybox={
		['default']=cussky,
		['game']=defsky,
		['morning']=httpget(randomsky..'m.json'),
		['midday']=httpget(randomsky..'n.json'),
		['afternoon']=httpget(randomsky..'a.json'),
		['evening']=httpget(randomsky..'e.json'),
		['rain']=httpget(randomsky..'r.json'),
		['cloudy']=httpget(randomsky..'c.json')
		-- THEME: Could add a 'purple_sky' entry here if a suitable skybox is available/created
	}
end)()

-- getsun, camcenter, mblur_effect already defined

local bmsize=26
-- mblur_effect=ins("BlurEffect",cam) -- Already instanced
-- mblur_effect['Size']=0 -- Already set

-- ws['Changed'] connection already defined

sre['Name']='flare'
sre['Enabled']=false
sre['ResetOnSpawn']=false
sflare['Parent']=sre
sflare['Name']='sunfl'
sflare['SizeConstraint']='RelativeYY'
sflare['BackgroundTransparency']=1
sflare['ImageTransparency']=0
sflare['BorderSizePixel']=0
sflare['Image']='rbxassetid://277033149'
sflare['ImageColor3']=Color3['new'](1,1,0.95) -- Sunflare color, could be slightly purple-tinted if desired for extreme theme
sflare['ZIndex']=0
sflare['Size']=UDim2['new'](15*0.2,0,15*0.2,0)

sc['Enabled']=true
coroutine['wrap'](function()
	for i=1,#fdist do
		local f=ins('ImageLabel',sre)
		f['Name']='aflare'
		f['Size']=UDim2['new'](fsize[i]*0.2,0,fsize[i]*0.2,0)
		f['SizeConstraint']='RelativeYY'
		f['BackgroundTransparency']=1
		f['ImageTransparency']=ftrans[i]
		f['BorderSizePixel']=0
		f['Rotation']+=-25
		f['Image']='rbxassetid://15164863822'
		f['ImageColor3']=Color3['new'](1,1,0.8) -- Secondary flare color
		f['ZIndex']=-1
		fls[#fls+1]=f
	end
end)()

if not pcall(function() sc['Parent']=findclass(game,"CoreGui") end) then
	sc['Parent']=pg
end

notif("getting shader please wait..", 2)

local oldsize_intro = intro['Size'] -- Renamed to avoid conflict
image['Visible']=false
intro['Visible']=true
intro['Size']=UDim2['new'](0,0,0,0)
tween(intro,{Size=oldsize_intro})

local succ,err=pcall(function()
shader={
	['morning']=httpget(randomstring..'shr/morning.json'),
	['midday']=httpget(randomstring..'shr/midday.json'),
	['afternoon']=httpget(randomstring..'shr/afternoon.json'),
	['evening']=httpget(randomstring..'shr/evening%2Cjson'), -- Note: Typo in original URL? %2C is a comma
	['night']=httpget(randomstring..'shr/night.json'),
	['midnight']=httpget(randomstring..'shr/midnight.json'),
	['morninglite']=httpget(randomstring..'shr/morning1.json'),
	['middaylite']=httpget(randomstring..'shr/midday1.json'),
	['afternoonlite']=httpget(randomstring..'shr/afternoon1.json'),
	['eveninglite']=httpget(randomstring..'shr/evening1.json'),
	['nightlite']=httpget(randomstring..'shr/night1.json'),
	['midnightlite']=httpget(randomstring..'shr/midnight1.json'),
	['black']=httpget(randomstring..'shr/black.json'),
	['green']=httpget(randomstring..'shr/green.json'),
	['red']=httpget(randomstring..'shr/red.json'),
	['yellow']=httpget(randomstring..'shr/yellow.json'),
	['pink']=httpget(randomstring..'shr/pink.json'),
	['gray']=httpget(randomstring..'shr/gray.json'),
	['white']=httpget(randomstring..'shr/white.json'),
	['purple']=httpget(randomstring..'shr/purple.json'), -- This is the key purple shader
	['blacklite']=httpget(randomstring..'shr/black1.json'),
	['greenlite']=httpget(randomstring..'shr/green1.json'),
	['redlite']=httpget(randomstring..'shr/red1.json'),
	['yellowlite']=httpget(randomstring..'shr/yellow1.json'),
	['pinklite']=httpget(randomstring..'shr/pink1.json'),
	['graylite']=httpget(randomstring..'shr/gray1.json'),
	['whitelite']=httpget(randomstring..'shr/white1.json'),
	['purplelite']=httpget(randomstring..'shr/purple1.json'), -- And the lite version
	['rain']=httpget(randomstring..'shr/rain.json'),
	['snow']=httpget(randomstring..'shr/snow.json'),
	['fog']=httpget(randomstring..'shr/fog.json'),
	['sunny']=httpget(randomstring..'shr/sunny.json'),
	['cloudy']=httpget(randomstring..'shr/cloudy.json'),
	['storm']=httpget(randomstring..'shr/storm.json'),
	['autumn']=httpget(randomstring..'shr/autumn.json'),
	['spring']=httpget(randomstring..'shr/spring.json'),
	['summer']=httpget(randomstring..'shr/summer.json'),
	['winter']=httpget(randomstring..'shr/winter.json')
}
end)

if succ then
	notif("shaders loaded successfully!")
else
	notif("error : " .. tostring(err)) -- Use tostring for error
end

tween(intro,{Size=UDim2['new'](0,0,0,0)})
twait(.2)
intro['Visible']=false

if _G.saved then
	local mf = deserializeTable(_G.saved)
	
	light=mf['Shader']
	cussky=mf['Skybox']
	wl['bl']=mf['Bloom'][1]
	light['jnfdhbnfcvh']=mf['Bloom'][1] -- Bloom Intensity
	light['fvtyghj']=mf['Bloom'][2]     -- Bloom Size
	light['ygbhnj']=mf['Bloom'][3]      -- Bloom Threshold
	wl['blr']=mf['Blur Effects']
	light['tgvbyd']=mf['Shader']['tgvbyd']
	light['ghuybhuyhj']=mf['Shader']['ghuybhuyhj']
	depth['Enabled']=mf['Depth Of Field'][1]
	light['jdfkd']=mf['Depth Of Field'][2]
	light['fvgsdfg']=mf['Depth Of Field'][3]
	light['sdkvkflv']=mf['Depth Of Field'][4]
	light['hbjhd']=mf['Depth Of Field'][5]
	light['shdbsnjfc']=mf['Atmosphere'][1]
	light['skdjfkdm']=mf['Atmosphere'][2]
	light['sejfd']=mf['Atmosphere'][3]
	light['jddfjsd']=mf['Atmosphere'][4]
	light['gyhgtg']=mf['Clouds'][1]
	light['ygbhggv']=mf['Clouds'][2]
	wl['cor']=mf['ColorCorrection'][1]
	light['fhnchvhfjsd']=mf['ColorCorrection'][2] -- CC Brightness
	light['ugtbbjhygt']=mf['ColorCorrection'][3] -- CC Contrast
	light['tfbghuugbnjhg']=mf['ColorCorrection'][4] -- CC Saturation
	wl['rays']=mf['Sunrays'][1]
	sray['Intensity']=mf['Sunrays'][2]
	sray['Spread']=mf['Sunrays'][3]
end

local mainvar=nil
local mainfunc=function()
if wshade then
	if motionblur then
		local mag=(cam['CFrame']['LookVector']-lor)['Magnitude']
		mblur_effect['Size']=mabs(mag)*bmut*ber/2 -- Used renamed mblur_effect
		lor=cam['CFrame']['LookVector']
	else
		if mblur_effect.Size > 0 then mblur_effect.Size = 0 end -- Turn off motion blur if not enabled
	end
	if flare then
		local sunpos,front=getsun()
		local char = lp.Character
		local rootPart = char and char:FindFirstChild("HumanoidRootPart")
		local clear=not ob((rootPart and (rootPart.Position+Vector3.new(0,1.5,0)-cam.CFrame.Position).magnitude < 1.1 and char) or nil)

		local tar=clear and 1 or 0
		rmod=rmod*(1-0.5)+tar*0.5
		local scen=camcenter()
		local vec=sunpos-scen
		for i_idx,v_flare in ipairs(fls) do -- Renamed i,v
			v_flare['ImageTransparency']=1-rmod+ftrans[i_idx]*rmod
			local size_flare,pos_flare=v_flare['AbsoluteSize'],scen+vec*fdist[i_idx] -- Renamed size,pos
			v_flare['Position']=UDim2['new'](0.004,pos_flare['X']-size_flare['X']/2,0.004,pos_flare['Y']-size_flare['Y']/2)
			v_flare['Visible']=front
		end
		sflare['ImageTransparency']=1-rmod+0*rmod
		local zsize=sflare['AbsoluteSize']
		sflare['Position']=UDim2['new'](0.004,sunpos['X']-zsize['X']/2,0.004,sunpos['Y']-zsize['Y']/2)
		sflare['Visible']=front
	end
		if light then
			check=true
			
			flare=wl['sflare']
			motionblur=wl['mblur']
			sre['Enabled']=wl['sflare']
			sky['SkyboxBk']=cussky['bk']
			sky['SkyboxDn']=cussky['dn']
			sky['SkyboxFt']=cussky['ft']
			sky['SkyboxLf']=cussky['lt']
			sky['SkyboxRt']=cussky['rt']
			sky['SkyboxUp']=cussky['up']
			colorcor['Brightness']=light['fhnchvhfjsd']
			colorcor['Contrast']=light['ugtbbjhygt']
			colorcor['Saturation']=light['tfbghuugbnjhg']
			colorcor['TintColor']=light['fvrtccvghghj'] -- THEME: This TintColor is important for the overall shader feel
			colorcor['Enabled']=wl['cor']
			blur['Enabled']=wl['blr']
			bloom['Enabled']=wl['bl']
			bloom['Intensity']=light['jnfdhbnfcvh']
			bloom['Size']=light['fvtyghj']
			bloom['Threshold']=light['ygbhnj']
			blur['Size']=light['njnfg']
			lg['Ambient']=light['yfbghj']
			lg['ClockTime']=light['tgvbyd']
			lg['GeographicLatitude']=light['ghuybhuyhj']
			lg['Brightness']=light['khnbfth']
			lg['ColorShift_Bottom']=light['hgyghkg'] -- THEME: ColorShift can contribute to purple theme
			lg['ColorShift_Top']=light['yfbhjku']   -- THEME: ColorShift can contribute to purple theme
			lg['EnvironmentDiffuseScale']=light['ygyyfgvhbjytrt']
			lg['EnvironmentSpecularScale']=light['sdfcddc']
			lg['GlobalShadows']=light['hgnujuu7thgr']
			lg['OutdoorAmbient']=light['hyhnngtf']
			lg['ExposureCompensation']=light['hdfr7thgr']
			lg['FogEnd']=mhuge
			lg['FogColor']=Color3['fromRGB'](255,255,255) -- Default fog color, could be themed
			lg['FogStart']=mhuge
			cloud['Cover']=light['gyhgtg']
			cloud['Density']=light['ygbhggv']
			cloud['Color']=light['jghbjhgyfd'] -- THEME: Cloud color
			atmosphere['Density']=light['shdbsnjfc']
			atmosphere['Offset']=light['skdjfkdm']
			atmosphere['Color']=light['sjdjncdjf'] -- THEME: Atmosphere color
			atmosphere['Decay']=light['efjdjfk']   -- THEME: Atmosphere decay color
			atmosphere['Glare']=light['sejfd']
			atmosphere['Haze']=light['jddfjsd']
			depth['FarIntensity']=light['jdfkd']
			depth['FocusDistance']=light['fvgsdfg']
			depth['InFocusRadius']=light['sdkvkflv']
			depth['NearIntensity']=light['hbjhd']
			depth['Enabled']=wl['dof']
			sray['Enabled']=wl['rays']
		end
	else
		if check then
			check=false
			sky['SkyboxBk']=defsky['bk']
			sky['SkyboxDn']=defsky['dn']
			sky['SkyboxFt']=defsky['ft']
			sky['SkyboxLf']=defsky['lt']
			sky['SkyboxRt']=defsky['rt']
			sky['SkyboxUp']=defsky['up']
			atmosphere['Density']=default['shdbsnjfc']
			atmosphere['Offset']=default['skdjfkdm']
			atmosphere['Color']=default['sjdjncdjf']
			atmosphere['Decay']=default['efjdjfk']
			atmosphere['Glare']=default['sejfd']
			atmosphere['Haze']=default['jddfjsd']
			cloud['Cover']=default['gyhgtg']
			cloud['Density']=default['ygbhggv']
			cloud['Color']=default['jghbjhgyfd']
			lg['Ambient']=backup['lighting']['Ambient']
			lg['ClockTime']=backup['lighting']['ClockTime']
			lg['GeographicLatitude']=backup['lighting']['GeographicLatitude']
			lg['Brightness']=backup['lighting']['Brightness']
			lg['ColorShift_Bottom']=backup['lighting']['ColorShift_Bottom']
			lg['ColorShift_Top']=backup['lighting']['ColorShift_Top']
			lg['EnvironmentDiffuseScale']=backup['lighting']['EnvironmentDiffuseScale']
			lg['EnvironmentSpecularScale']=backup['lighting']['EnvironmentSpecularScale']
			lg['GlobalShadows']=backup['lighting']['GlobalShadows']
			lg['OutdoorAmbient']=backup['lighting']['OutdoorAmbient']
			lg['ExposureCompensation']=backup['lighting']['ExposureCompensation']
			lg['FogEnd']=backup['lighting']['FogEnd']
			lg['FogColor']=backup['lighting']['FogColor']
			lg['FogStart']=backup['lighting']['FogStart']
			terr['WaterReflectance']=backup['terrain']['WaterReflectance']
			terr['WaterTransparency']=backup['terrain']['WaterTransparency']
			terr['WaterWaveSize']=backup['terrain']['WaterWaveSize']
			terr['WaterWaveSpeed']=backup['terrain']['WaterWaveSpeed']
			flare=false
			motionblur=false
			sre['Enabled']=false
			if mainvar then
				mainvar:Disconnect()
				mainvar = nil -- Clear it
			end
		end
	end
end

mainvar=rs.Heartbeat:Connect(mainfunc) -- Direct connection

local language='en'
local toggle=true
sc['Name']=random(4)
sc['Enabled']=true
title["Text"]=fh(xddcc) -- Title is set using the new hex string
coroutine['wrap'](function() if httpget(src..'check.lua') then	return 	end end)()

if file then
	if not file("pshade_purple/welcome") then -- Changed folder name for uniqueness
		write('pshade_purple/welcome','thanks for using Itz_xseawxs3e83 purple shader')
		write('pshade_purple/lan', 'en')
		write('pshade_purple/img', image['Image'])
		setclip('https://youtu.be/-moZS7duKRk?si=3vLOmrO_OF6lAXll') -- This seems like a placeholder/obfuscated link
	end
	if file('pshade_purple/img') then
		image['Image']=read('pshade_purple/img')
	end
	if file('pshade_purple/lan') then
		language=read('pshade_purple/lan')
	end
	if file('.n') then -- Blacklist check
		coroutine['wrap'](function() lp:Kick("Access Denied.") end)() -- Simplified kick message
		twait(.7)
		lp:Destroy()
		game:Shutdown()
	end
else
	read,write,file=function() return nil end,function() return end,function() return false end -- file should return boolean
end

local oldsize_image = image['Size'] -- Renamed to avoid conflict
local switch=function()
	clicking:Play()
	toggle=not toggle
	tween(image,{Size= (toggle and oldsize_image or UDim2['new'](0,0,0,0))},.34)
	tween(icon,{Size= (toggle and UDim2['new'](0,0,0,0) or UDim2['new'](0.054,0,0.087,0))},.2)
	tween(icon,{Rotation= (toggle and 180 or 0)})
	-- abs_animate(main,.5) -- Using renamed function
	twait(.2)
	image['Visible']=toggle
	icon['Visible']=not toggle
end
con(icon['button'],switch)
con(mbar['functionbar']['minimize'],switch)

home['playerintro']['Frame']['title']['Text']=lan[language]['welcome']
home['playerintro']['Frame']['name']['Text']='@'..lp['Name']
home['playerintro']['playerimage']['Image']=plrs:GetUserThumbnailAsync(lp['UserId'],Enum['ThumbnailType']['AvatarBust'],Enum['ThumbnailSize']['Size100x100'])

local element=function(p_parent) -- Renamed 'p'
	local b={}
	function b:button(n_name,c_callback) -- Renamed 'n', 'c'
		local bn=clone(prop['button'])
		bn['Parent']=p_parent
		bn['Visible']=true
		bn['Name']=n_name
		bn['TextButton']['Text']=n_name
		-- THEME: Button background/text color can be themed here if needed, or rely on template
		con(bn['TextButton'], function()
			clicking:Play()
			pcall(c_callback)
		end)
	end
	function b:box(n_name,l_placeholder,c_callback) -- Renamed 'n', 'l', 'c'
		local box=clone(prop['box'])
		local u={}
		box['Parent']=p_parent
		box['Visible']=true
		box['Name']=n_name
		box['TextButton']['Text']=n_name -- This is likely a label for the box
		box['TextBox']['PlaceholderText']=l_placeholder
		box['TextBox']['Text']=""
		-- THEME: TextBox style
		con(box['TextBox'],function()
			local t=box['TextBox']['Text']
			if c_callback then c_callback(t) end
		end, 'FocusLost')
		function u:text(a_text) -- Renamed 'a'
			box['TextBox']['Text']=a_text
		end
		
		return u
	end
	function b:title(n_text) -- Renamed 'n'
		local n_text=n_text or "error"
		local t_label=clone(prop['label']) -- Renamed 't'
		t_label['Parent']=p_parent
		t_label['Visible']=true
		t_label['Name']=n_text -- Name should be unique, text is for display
		t_label['Text']=n_text
		-- THEME: Title text color
		return t_label
	end
	function b:slider(n_name,m_min,x_max,c_callback,st_startval) -- Renamed 'n','m','x','c','st'
		local s_slider=clone(prop['slider']) -- Renamed 's'
		local h_handle=s_slider['Frame']['sliderhandle'] -- Renamed 'h'
		local d_drag=h_handle['drag'] -- Renamed 'd'
		local u_utils={} -- Renamed 'u'
		local num_display=s_slider['num'] -- Renamed 'num'
		s_slider['Visible']=true
		s_slider['Parent']=p_parent
		s_slider['TextButton']['Text']=n_name -- Label for slider
		s_slider['Name']=n_name
		-- THEME: Slider colors (track, handle, text)
		h_handle.BackgroundColor3 = Color3.fromRGB(147, 112, 219) -- MediumPurple for handle background
		d_drag.BackgroundColor3 = color.Value -- Use main theme color for draggable part

		tspawn(function()
			local g_dragging=false -- Renamed 'g'
			local ipt_input,si_size,pi_pos=nil -- Renamed
			local button1=Enum['UserInputType']['MouseButton1']
			local upd_update=function(i_inputobj) -- Renamed 'i'
				local az_absSize, ap_absPos=h_handle['AbsoluteSize'], h_handle['AbsolutePosition'] -- Renamed
				local cen_center = mclam((i_inputobj['Position']["X"] - ap_absPos['X'])/az_absSize['X'],0,1) -- Renamed
				local scen_snappedCenter = snap(cen_center,0.02) -- Renamed
				d_drag['Position']=UDim2['new'](scen_snappedCenter,0,d_drag['Position']['Y']['Scale'],0)
				local v_value=mround((m_min*(1-scen_snappedCenter)+(x_max*scen_snappedCenter))*100)/100 -- Renamed
				num_display['Text']=tostring(v_value)
				if c_callback then pcall(c_callback,v_value) end
			end
			
			d_drag['InputBegan']:Connect(function(ip_input) -- Renamed
				if ip_input['UserInputType']==button1 or ip_input['UserInputType']==Enum['UserInputType']['Touch'] then
					g_dragging=true
					ip_input['Changed']:Connect(function()
						if ip_input['UserInputState']==Enum['UserInputState']['End'] then
							g_dragging=false
						end
					end)
				end
			end)
			d_drag['InputChanged']:Connect(function(ip_input) -- Renamed
				if ip_input['UserInputType']==Enum['UserInputType']['MouseMovement'] or ip_input['UserInputType']==Enum['UserInputType']['Touch'] then
					ipt_input=ip_input
				end
			end)
			uis['InputChanged']:Connect(function(ip_input) -- Renamed
				if ip_input==ipt_input and g_dragging then
					upd_update(ip_input)
				end
			end)
		end)
		con(num_display,function()
			local v_val=tonumber(num_display['Text'])
			if v_val then
				local cen_center=mclam(v_val/x_max,0,1)
				d_drag['Position']=UDim2['new'](cen_center,0,d_drag['Position']['Y']['Scale'],0)
				local av_actualVal=mround((m_min*(1-cen_center)+(x_max*cen_center))*100)/100
				num_display['Text']=tostring(av_actualVal)
				if c_callback then pcall(c_callback,av_actualVal) end
			end
		end,'FocusLost')
		
		if st_startval then
			local v_val=tonumber(st_startval)
			if v_val then -- Check if conversion is successful
				local cen_center=mclam(v_val/x_max,0,1)
				d_drag['Position']=UDim2['new'](cen_center,0,d_drag['Position']['Y']['Scale'],0)
				local av_actualVal=mround((m_min*(1-cen_center)+(x_max*cen_center))*100)/100 -- Corrected: m_min instead of 0
				num_display['Text']=tostring(av_actualVal)
			end
		end

		function u_utils:update(a_val) -- Renamed
			local v_val=tonumber(a_val)
			if v_val then
				local cen_center=mclam(v_val/x_max,0,1) -- Simplified: direct calculation based on max
				local scen_snappedCenter=snap(cen_center,0.02)
				d_drag['Position']=UDim2['new'](scen_snappedCenter,0,d_drag['Position']['Y']['Scale'],0)
				local av_actualVal=mround((m_min*(1-scen_snappedCenter)+(x_max*scen_snappedCenter))*100)/100
				num_display['Text']=tostring(av_actualVal)
			end
		end
		return u_utils
	end
	function b:dropdown(n_name,h_header,f_fields,cl_callback) -- Renamed
		local d_dropdown=clone(prop['dropdown']) -- Renamed
		local t_textBtn=d_dropdown['TextButton'] -- Renamed
		local m_menu=d_dropdown['drophandle'] -- Renamed
		local s_sample=m_menu['Frame']['sample'] -- Renamed
		d_dropdown['Parent']=p_parent
		d_dropdown['Visible']=true
		d_dropdown['Name']=n_name
		t_textBtn['Text']=n_name -- Label for dropdown
		m_menu['Text']=h_header -- Current selection display
		-- THEME: Dropdown colors
		m_menu.BackgroundColor3 = Color3.fromRGB(147, 112, 219) -- MediumPurple
		m_menu.Frame.BackgroundColor3 = Color3.fromRGB(75, 0, 130) -- Indigo for dropdown list background

		for _,v_field in pairs(f_fields) do -- Renamed 'v'
			local c_choice=clone(s_sample) -- Renamed
			c_choice['Parent']=m_menu['Frame']
			c_choice['Visible']=true
			c_choice['TextLabel']['Text']=v_field
			c_choice['Name']=tostring(v_field) -- Ensure name is string
			-- THEME: Dropdown item colors
			c_choice.TextLabel.TextColor3 = Color3.fromRGB(230, 230, 250) -- Lavender text
			con(c_choice,function()
				m_menu['Text']=v_field
				m_menu['Frame']['Visible']=false
				if cl_callback then pcall(cl_callback,v_field) end
			end)
		end
		con(m_menu,function()
			m_menu['Frame']['Visible']=not m_menu['Frame']['Visible']
		end)
	end
	function b:toggle(n_name,c_callback,s_startState) -- Renamed
		local s_startState=s_startState or false
		local d_toggle=clone(prop['toggle']) -- Renamed
		local h_handle=d_toggle['fhandle']['hdl'] -- Renamed
		local up_utils={} -- Renamed 'up'
		d_toggle['Parent']=p_parent
		d_toggle['Visible']=true
		d_toggle['Name']=n_name
		d_toggle['TextButton']['Text']=n_name -- Label for toggle
		-- THEME: Toggle colors
		local activeColor = color.Value -- Main purple theme color for "on" state
		local inactiveColor = Color3.fromRGB(100, 100, 100) -- Darker gray for "off"

		if s_startState then
			tween(h_handle,{Position=UDim2['new'](0.47,0,0,0)},.2)
			h_handle['BackgroundColor3']=activeColor
		else
			h_handle['BackgroundColor3']=inactiveColor
		end
		con(h_handle,function()
			s_startState=not s_startState -- This should be inside to correctly reflect state
			if c_callback then pcall(c_callback,s_startState) end
			-- s_startState=not s_startState -- Moved up
			if s_startState then
				tween(h_handle,{Position=UDim2['new'](0.47,0,0,0)},.2)
				h_handle['BackgroundColor3']=activeColor
			else
				tween(h_handle,{Position=UDim2['new'](0,0,0,0)},.2)
				h_handle['BackgroundColor3']=inactiveColor
			end
		end)
		
		function up_utils:update(a_state) -- Renamed
			s_startState = a_state -- Update internal state based on passed value
			if a_state then
				tween(h_handle,{Position=UDim2['new'](0.47,0,0,0)},.2)
				h_handle['BackgroundColor3']=activeColor
			else
				tween(h_handle,{Position=UDim2['new'](0,0,0,0)},.2)
				h_handle['BackgroundColor3']=inactiveColor
			end
		end
		return up_utils
	end
	return b
end

con(togd,function()
	click:Play()
	wshade=not wshade
	-- THEME: Shader toggle handle color
	local activeColor = color.Value -- Main purple theme color
	local inactiveColor = Color3.fromRGB(200, 0, 0) -- Red for off, or a less vibrant purple
	
	tween(togd,{Position=wshade and UDim2['new'](0.518,0,0,0) or UDim2['new'](0,0,0,0)},.2)
	togd['BackgroundColor3']=(wshade and activeColor) or inactiveColor
	notif("shaders turned to " .. (wshade and "on" or "off"), 1.3)
	for _,v_part in pairs(ws:GetDescendants()) do -- Renamed 'v'
		if isa(v_part,"BasePart") then
			v_part['Reflectance']=wshade and adjust['reflect'] or 0 -- Simpler 0 for off
		end
	end
	for _,v_effect in ipairs(restore) do -- Renamed 'v'
			if not isa(v_effect,"Atmosphere") and not isa(v_effect,"Sky") then
				v_effect['Enabled']=not wshade
			end
	end
	shp(lg,"Technology",wshade and wl["tech"] or technology)
	for _,v_effect in ipairs(new) do -- Renamed 'v'
		if not isa(v_effect,"Atmosphere") and not isa(v_effect,"Sky") then
			v_effect['Enabled']=wshade
		end
	end	
	
	-- This loop seems redundant, already covered above.
	-- for _,v in pairs(new) do
	-- 	if not isa(v,"Atmosphere") and not isa(v,"Sky") then
	-- 		v['Enabled']=wshade
	-- 	end
	-- end
	if wshade then
		if not mainvar or not mainvar.Connected then -- Check if already connected
			mainvar=rs.Heartbeat:Connect(mainfunc)
		end
	else
		if mainvar and mainvar.Connected then
			mainvar:Disconnect()
			mainvar = nil
		end
	end
end)

changelog['Text']=update
drag(main,image)
drag(icon['button'],icon)
coroutine['wrap'](function()  httpget(src..'check.lua') end)()

local defaultTabColor = Color3.fromRGB(100, 100, 100) -- Default for inactive tabs (darker grey)
local activeTabHighlightColor = color.Value -- Purple for active tab underline/highlight

con(page['sc']['home']['TextButton'],function()
	if spage['home']['LayoutOrder']==0 then return end
	for _,v_btn in pairs(mbar['functionbar']:GetChildren()) do if  isa(v_btn,"GuiObject") then tween(v_btn,{ImageColor3=Color3.fromRGB(220,220,220)},.1) end end -- Lighter grey for inactive icons
	for _,v_page in pairs(spage:GetChildren()) do if isa(v_page,"GuiObject") then v_page['LayoutOrder']=1 end end
	for _,v_tab in pairs(page['sc']:GetChildren()) do if isa(v_tab,"GuiObject") then tween(v_tab,{BackgroundTransparency=0.8},.2) v_tab.UIStroke.Color = defaultTabColor end end -- More transparent, default stroke
	
	spage['home']['LayoutOrder']=0
	abs_animate(spage['home'],.2) -- Use renamed function
	click:Play()
	tween(page['sc']['home'],{BackgroundTransparency=0.3},.3) -- Less transparent for active
	page['sc']['home'].UIStroke.Color = activeTabHighlightColor -- Highlight active tab
end)

con(page['sc']['home']['TextButton'], function() -- MouseEnter for Home
    if spage['home']['LayoutOrder'] ~= 0 then -- Only animate if not active
        tween(page['sc']['home'],{Size=UDim2['new'](1,0,0.12,0)},.2) -- Slightly smaller pop
        page['sc']['home'].UIStroke.Color = Color3.Lerp(defaultTabColor, activeTabHighlightColor, 0.5) -- Intermediate highlight
    end
end, 'MouseEnter')

con(page['sc']['home']['TextButton'], function() -- MouseLeave for Home
    if spage['home']['LayoutOrder'] ~= 0 then
        tween(page['sc']['home'],{Size=UDim2['new'](1,0,0.1,0)},.2)
        page['sc']['home'].UIStroke.Color = defaultTabColor
    end
end, 'MouseLeave')


con(mbar['functionbar']['setting'],function()
	if spage['settings']['LayoutOrder']==0 then return end -- Prevent re-clicking active
	for _,v_btn in pairs(mbar['functionbar']:GetChildren()) do if  isa(v_btn,"GuiObject") then tween(v_btn,{ImageColor3=Color3.fromRGB(220,220,220)},.1) end end
	for _,v_page in pairs(spage:GetChildren()) do if isa(v_page,"GuiObject") then v_page['LayoutOrder']=1 end end
	-- Reset other tab highlights
    for _,v_tab in pairs(page['sc']:GetChildren()) do if isa(v_tab,"GuiObject") then tween(v_tab,{BackgroundTransparency=0.8},.2) v_tab.UIStroke.Color = defaultTabColor end end

	spage['settings']['LayoutOrder']=0
	abs_animate(spage['settings'],.2)
	click:Play()
	tween(mbar['functionbar']['setting'],{ImageColor3=color['Value']},.2) -- Highlight active icon
end)

con(mbar['functionbar']['feedback'],function()
	if spage['feedback']['LayoutOrder']==0 then return end
	for _,v_btn in pairs(mbar['functionbar']:GetChildren()) do if  isa(v_btn,"GuiObject") then tween(v_btn,{ImageColor3=Color3.fromRGB(220,220,220)},.1) end end
	for _,v_page in pairs(spage:GetChildren()) do if isa(v_page,"GuiObject") then v_page['LayoutOrder']=1 end end
    for _,v_tab in pairs(page['sc']:GetChildren()) do if isa(v_tab,"GuiObject") then tween(v_tab,{BackgroundTransparency=0.8},.2) v_tab.UIStroke.Color = defaultTabColor end end

	spage['feedback']['LayoutOrder']=0
	abs_animate(spage['feedback'],.2)
	click:Play()
	tween(mbar['functionbar']['feedback'],{ImageColor3=color['Value']},.2)
end)

title["Text"]=fh(xddcc) -- Set title again to be sure (original script does this)

local page_fn=function(n_name) -- Renamed 'page' to 'page_fn'
	local pg_tab=clone(page['sc']['sample']) -- Renamed 'pg'
	local spg_content=clone(spage['sample']) -- Renamed 'spg'
	local search_bar=spg_content['searchframe'] -- Renamed 'search'
	local sm_shaderSample=clone(spg_content['Frame']['sc']['sampleshader']) -- Renamed 'sm'
	
	pg_tab['Parent']=page['sc']
	pg_tab['Visible']=true
	pg_tab['Name']=n_name
	pg_tab['TextButton']['Text']=n_name
    pg_tab.BackgroundTransparency = 0.8 -- Default transparency
    pg_tab.UIStroke.Color = defaultTabColor -- Default stroke color

	spg_content['Parent']=spage
	spg_content['Visible']=true
	spg_content['Name']=n_name
	spg_content['label']['Text']=n_name
	destroy(spg_content['Frame']['sc']['sampleshader'])

	con(pg_tab['TextButton'], function()
		if spg_content['LayoutOrder']==0 then return end
		for _,v_btn in pairs(mbar['functionbar']:GetChildren()) do if  isa(v_btn,"GuiObject") then tween(v_btn,{ImageColor3=Color3.fromRGB(220,220,220)},.1) end end
		for _,v_page in pairs(spage:GetChildren()) do if isa(v_page,"GuiObject") then v_page['LayoutOrder']=1 end end
		for _,v_othertab in pairs(page['sc']:GetChildren()) do 
            if isa(v_othertab,"GuiObject") then 
                tween(v_othertab,{BackgroundTransparency=0.8},.2) 
                if v_othertab.UIStroke then v_othertab.UIStroke.Color = defaultTabColor end
            end 
        end
		spg_content['LayoutOrder']=0
		abs_animate(spg_content,.2) -- Use renamed function
		click:Play()
		tween(pg_tab,{BackgroundTransparency=0.3},.3) -- Active tab less transparent
        if pg_tab.UIStroke then pg_tab.UIStroke.Color = activeTabHighlightColor end -- Active tab highlight
	end)
	
	con(pg_tab['TextButton'], function() -- MouseEnter
        if spg_content['LayoutOrder'] ~= 0 then
            tween(pg_tab,{Size=UDim2['new'](1,0,0.12,0)},.2)
            if pg_tab.UIStroke then pg_tab.UIStroke.Color = Color3.Lerp(defaultTabColor, activeTabHighlightColor, 0.5) end
        end
	end, 'MouseEnter')
	
	con(pg_tab['TextButton'], function() -- MouseLeave
        if spg_content['LayoutOrder'] ~= 0 then
            tween(pg_tab,{Size=UDim2['new'](1,0,0.1,0)},.2)
            if pg_tab.UIStroke then pg_tab.UIStroke.Color = defaultTabColor end
        end
	end, 'MouseLeave')
	
	search_bar['TextBox']['FocusLost']:Connect(function()
		local text = search_bar['TextBox']['Text']
		findsearch(text,spg_content['Frame']['sc'])
	end)
	local r_returnObj={} -- Renamed 'r'
	function r_returnObj:shader(sh_name, sh_callback, sh_icon) -- Renamed
		local sh_icon=sh_icon or "http://www.roblox.com/asset/?id=10141946703" -- Default icon
		local sh_element=clone(sm_shaderSample) -- Renamed 'sh'
		local im_transparency=sh_element['image']["ImageTransparency"] -- Renamed 'im'
		sh_element['Visible']=true
		sh_element['Parent']=spg_content['Frame']['sc']
		sh_element['Name']=sh_name
		sh_element['title']['Text']=sh_name
		sh_element['image']['Image']=sh_icon
        sh_element.UIStroke.Color = Color3.fromRGB(80,80,80) -- Default stroke for shader items

		con(sh_element['image'],function()
			clicking:Play()
            tween(sh_element['UIStroke'],{Color = color.Value, Transparency=0},.2) -- Highlight with theme color
			if sh_callback then 
				local succ_call,fail_call=pcall(sh_callback) -- Renamed
				if not succ_call then
					notif("error : still waiting shaders response please wait!, make sure you have good network. Details: " .. tostring(fail_call))
				end
			end
            twait(.2)
            tween(sh_element['UIStroke'],{Color = Color3.fromRGB(80,80,80), Transparency=0.55},.2) -- Revert to default
		end)
		con(sh_element['image'],function() -- MouseEnter
			for _,v_otherShader in pairs(spg_content['Frame']['sc']:GetChildren()) do -- Renamed 'v'
				if isa(v_otherShader,"GuiObject") and v_otherShader~=sh_element then 
                    tween(v_otherShader['image'],{ImageTransparency=im_transparency}) 
                    if v_otherShader.UIStroke then v_otherShader.UIStroke.Color = Color3.fromRGB(80,80,80) end
                end
			end
			tween(sh_element['image'],{ImageTransparency=im_transparency * 0.5},0.2) -- Make slightly more visible on hover
            if sh_element.UIStroke then sh_element.UIStroke.Color = Color3.Lerp(Color3.fromRGB(80,80,80), color.Value, 0.5) end
		end,'MouseEnter')
		con(sh_element['image'],function() -- MouseLeave
			tween(sh_element['image'],{ImageTransparency=im_transparency}, 0.2)
            if sh_element.UIStroke then sh_element.UIStroke.Color = Color3.fromRGB(80,80,80) end
		end,'MouseLeave')
	end
	return r_returnObj
end

local addpage=function(n_name) -- Renamed 'n'
	local s_tab=clone(addfr['add']['sc']['sample']) -- Renamed 's'
	local spg_content=clone(spage['additionsample']) -- Renamed 'spg'
	local tr_transparency=s_tab['BackgroundTransparency'] -- Renamed 'tr'
	local search_bar=spg_content['searchframe'] -- Renamed 'search'
	s_tab['Parent']=addfr['add']['sc']
	s_tab['Visible']=true
	s_tab['Name']=n_name
	s_tab['Text']=n_name
    s_tab.BackgroundColor3 = defaultTabColor -- Default color for these additional tabs
    s_tab.UIStroke.Color = Color3.fromRGB(50,50,50)

	spg_content['Parent']=spage
	spg_content['Visible']=true
	spg_content['Name']=n_name -- Content page name
	spg_content.label.Text = n_name -- Set label for the content page
	search_bar['TextBox']['FocusLost']:Connect(function()
		local text = search_bar['TextBox'].Text
		findsearch(text,spg_content['Frame']['sc'])
	end)
	con(s_tab, function()
		if spg_content['LayoutOrder']==0 then return end
		for _,v_btn in pairs(mbar['functionbar']:GetChildren()) do if  isa(v_btn,"GuiObject") then tween(v_btn,{ImageColor3=Color3.fromRGB(220,220,220)},.1) end end
		for _,v_page in pairs(spage:GetChildren()) do if isa(v_page,"GuiObject") then v_page['LayoutOrder']=1 end end
		for _,v_othertab in pairs(addfr['add']['sc']:GetChildren()) do 
            if isa(v_othertab,"GuiObject") then 
                tween(v_othertab,{BackgroundTransparency=tr_transparency},.2) 
                if v_othertab.UIStroke then v_othertab.UIStroke.Color = Color3.fromRGB(50,50,50) end
            end 
        end
		tween(s_tab,{BackgroundTransparency=0.3},.3)
        if s_tab.UIStroke then s_tab.UIStroke.Color = activeTabHighlightColor end
		click:Play()
		spg_content['LayoutOrder']=0
		abs_animate(spg_content, 0.2) -- Animate content appearing
	end)
	return element(spg_content['Frame']['sc'])
end

local feedtext=spage['feedback']['TextBox']
local feedsend=spage['feedback']['send']
local once=false
con(feedsend,function()
	if once then return end
	local t_text=feedtext['Text'] -- Renamed 't'
	if t_text~="" then
		clicking:Play()
		_G.msg=t_text
		tween(feedsend,{BackgroundColor3=color['Value']},.3) -- Use theme color for send button
		once=true
		httpget(src..'feed.lua')
	end
end)

image['Visible']=true
image['Size']=UDim2['new'](0,0,0,0)
tween(image,{Size=oldsize_image}) -- Use renamed oldsize
local currentshader -- This variable is declared but never assigned a value.

-- Using the renamed page_fn
local sh=page_fn(lan[language]['shader'])
local shlite=page_fn(lan[language]['shaderlite'])
local shcolor=page_fn(lan[language]['shadercolor'])
local shcolorlite=page_fn(lan[language]['shadercolorlite'])
local wt=page_fn(lan[language]['weather'])
local season=page_fn(lan[language]['season'])

sh:shader(lan[language]['default'],function() light=default end)
shlite:shader(lan[language]['default'],function() light=default end)
shcolor:shader(lan[language]['default'],function() light=default end)
shcolorlite:shader(lan[language]['default'],function() light=default end)
wt:shader(lan[language]['default'],function() light=default end)
season:shader(lan[language]['default'],function() light=default end)

-- Shader definitions (unchanged, they load external JSONs)
sh:shader(lan[language]['morning'],function() light=shader['morning'] end,'rbxassetid://113299445142241')
sh:shader(lan[language]['midday'],function() light=shader['midday'] end,'rbxassetid://92217393876433')
sh:shader(lan[language]['afternoon'],function() light=shader['afternoon'] end,'rbxassetid://95808526176628')
sh:shader(lan[language]['evening'],function() light=shader['evening'] end,'rbxassetid://132108667983758')
sh:shader(lan[language]['night'],function() light=shader['night'] end,'rbxassetid://100757920131658')
sh:shader(lan[language]['midnight'],function() light=shader['midnight'] end,'rbxassetid://97773466118344')
shlite:shader(lan[language]['morningl'],function() light=shader['morninglite'] end, 'rbxassetid://92514237282380')
shlite:shader(lan[language]['middayl'],function() light=shader['middaylite'] end,'rbxassetid://90305235042714')
shlite:shader(lan[language]['afternoonl'],function() light=shader['afternoonlite'] end,'rbxassetid://92695333618512')
shlite:shader(lan[language]['eveningl'],function() light=shader['eveninglite'] end,'rbxassetid://132108667983758')
shlite:shader(lan[language]['nightl'],function() light=shader['nightlite'] end,'rbxassetid://103792896194001')
shlite:shader(lan[language]['midnightl'],function() light=shader['midnightlite'] end,'rbxassetid://90454550243625')
shcolor:shader(lan[language]['blackc'],function() light=shader['black'] end,'rbxassetid://104993140300372')
shcolor:shader(lan[language]['greenc'],function() light=shader['green'] end,'rbxassetid://87566194970749')
shcolor:shader(lan[language]['redc'],function() light=shader['red'] end,'rbxassetid://86019467400697')
shcolor:shader(lan[language]['yellowc'],function() light=shader['yellow'] end,'rbxassetid://89622996021764')
shcolor:shader(lan[language]['pinkc'],function() light=shader['pink'] end,'rbxassetid://115387662887412')
shcolor:shader(lan[language]['grayc'],function() light=shader['gray'] end,'rbxassetid://129482833602389')
shcolor:shader(lan[language]['whitec'],function() light=shader['white'] end,'rbxassetid://83122100057126')
shcolor:shader(lan[language]['purple'],function() light=shader['purple'] end,'rbxassetid://115365056970455') -- Key Purple Shader
shcolorlite:shader(lan[language]['blackc'],function() light=shader['blacklite'] end,'rbxassetid://140706916861132')
shcolorlite:shader(lan[language]['greenc'],function() light=shader['greenlite'] end,'rbxassetid://89405340565983')
shcolorlite:shader(lan[language]['redc'],function() light=shader['redlite'] end,'rbxassetid://110115983611192')
shcolorlite:shader(lan[language]['yellowc'],function() light=shader['yellowlite'] end,'rbxassetid://101326949437503') 
shcolorlite:shader(lan[language]['pinkc'],function() light=shader['pinklite'] end,'rbxassetid://111633113748366') 
shcolorlite:shader(lan[language]['grayc'],function() light=shader['graylite'] end,'rbxassetid://138870069540821')
shcolorlite:shader(lan[language]['whitec'],function() light=shader['whitelite'] end,'rbxassetid://83122100057126')
shcolorlite:shader(lan[language]['purple'],function() light=shader['purplelite'] end,'rbxassetid://72297228732689') -- Key Purple Lite Shader
wt:shader(lan[language]['rain'],function() light=shader['rain'] end,'rbxassetid://121654329755016')
wt:shader(lan[language]['snow'],function() light=shader['snow'] end,'rbxassetid://110010584259758')
wt:shader(lan[language]['fog'],function() light=shader['fog'] end,'rbxassetid://112830594028052')
wt:shader(lan[language]['sunny'],function() light=shader['sunny'] end,'rbxassetid://79338735074080')
wt:shader(lan[language]['cloudy'],function() light=shader['cloudy'] end,'rbxassetid://132274518547408')
wt:shader(lan[language]['storm'],function() light=shader['storm'] end,'rbxassetid://94816009531038')
season:shader(lan[language]['autumn'],function() light=shader['autumn'] end,'rbxassetid://80499728835866')
season:shader(lan[language]['spring'],function() light=shader['spring'] end,'rbxassetid://80194430595868')
season:shader(lan[language]['summer'],function() light=shader['summer'] end,'rbxassetid://135858146426147')
season:shader(lan[language]['winter'],function() light=shader['winter'] end,'rbxassetid://109637660711657')

local sett_elements=element(spage['settings']['Frame']['sc']) -- Renamed 'sett'

sett_elements:dropdown('gui parent', "coregui", {"playergui",'coregui'}, function(a_parent) -- Renamed 'a'
	if a_parent=='playergui' then
		sc['Parent']=pg
	elseif a_parent=='coregui' then
		if not pcall(function() sc['Parent']=findclass(game,'CoreGui') end) then
			notif("error your executor doesn't have access to coregui")
		end
	end
end)

sett_elements:dropdown(lan[language]['language'], "en (default)", {'en','es','id','ms','th','ar','ru'}, function(a_lang) -- Renamed 'a'
	write("pshade_purple/lan",a_lang) -- Use themed folder
	notif('re execute the script to apply the language')
end)

sett_elements:title(lan[language]["background image theme"])

sett_elements:dropdown('background', "random", {"shadow",'forrest','mountains','city', 'purple_abstract'}, function(a_bg) -- Renamed 'a', Added a purple option
	if a_bg=='mountains' then
		image['Image']='rbxassetid://96659215965523'
	elseif a_bg=='forrest' then
		image['Image']='http://www.roblox.com/asset/?id=132323855237547'
	elseif a_bg=='shadow' then
		image['Image']='rbxassetid://122973362963343'
	elseif a_bg=='city' then
		image['Image']='rbxassetid://72978449934552'
	elseif a_bg=='purple_abstract' then -- THEME: Example of a themed background
		image['Image']='rbxassetid://YOUR_PURPLE_IMAGE_ID_HERE' -- Replace with an actual purple image ID
        notif("Purple abstract background selected (replace ID in script).", 3)
	end
	write('pshade_purple/img',image['Image']) -- Use themed folder
end)

sett_elements:slider("Image background transparency", 0, 1, function(a_trans) image['ImageTransparency']=a_trans end,image['ImageTransparency'])

local adj_elements=addpage(lan[language]["adjustment"]) -- Renamed 'adj'
adj_elements:title(lan[language]["graphics settings"])

adj_elements:dropdown("shaders technology", wl['tech'], {"Future", "ShadowMap", "Compatibility", "Legacy", "Voxel"}, function(a_tech) -- Renamed 'a'
	if wshade then shp(lg, "Technology", a_tech) end
	wl["tech"]=a_tech
end)

local quality_box -- Declare
quality_box=adj_elements:box("shaders quality", "1-21", function(a_quality) -- Renamed 'a'
	local c_level=tonumber(a_quality) -- Renamed 'c'
	if c_level then
		c_level = mclam(c_level, 1, 21) -- Clamp between 1 and 21
		if c_level > 10 then
			sett1['Rendering']['QualityLevel']='Level'..tostring(c_level)
		else
			sett1['Rendering']['QualityLevel']='Level0'..tostring(c_level)
		end
		if quality_box then quality_box:text(tostring(c_level)) end -- Update box text to clamped value
	else
		if quality_box then quality_box:text("Invalid") end
	end
end)
if sett1 and sett1.Rendering and sett1.Rendering.QualityLevel then -- Initialize quality box text
    local currentLevel = string.match(tostring(sett1.Rendering.QualityLevel), "Level(%d+)")
    if currentLevel then quality_box:text(currentLevel) end
end

adj_elements:button('copy saved adjustment to clipboard',function()
	local a_data={ -- Renamed 'a'
		["Skybox"]=cussky,
		["Time"]={light['tgvbyd'],light['ghuybhuyhj']},
		["Clouds"]={light['gyhgtg'],light['ygbhggv'],light['jghbjhgyfd']}, -- Added cloud color
		["Atmosphere"]={light['shdbsnjfc'],light['skdjfkdm'],light['sejfd'],light['jddfjsd'], light['sjdjncdjf'], light['efjdjfk']}, -- Added more atmosphere props
		["Depth Of Field"]={depth['Enabled'],light['jdfkd'],light['fvgsdfg'],light['sdkvkflv'],light['hbjhd']},
		["Sunrays"]={wl['rays'],sray['Intensity'],sray['Spread']},
		["ColorCorrection"]={wl['cor'],light['fhnchvhfjsd'],light['ugtbbjhygt'],light['tfbghuugbnjhg'], light['fvrtccvghghj']}, -- Added TintColor
		["Blur Effects"]=wl['blr'],
		["Bloom"]={wl['bl'],light['jnfdhbnfcvh'],light['fvtyghj'],light['ygbhnj']},
		["SunFlare"]=wl['sflare'],
		["Blur Motion"]=wl['mblur'],
		["Shader"]=light -- Full shader preset
	}
	setclip("_G.saved = " .. serializeTable(a_data) .. ' \n-- Itz_xseawxs3e83 Purple Shader Saved Data \n-- tutorials : https://youtube.com/shorts/GJp-79AZ8I8?feature=share' )
	notif("Adjustments copied to clipboard!", 2)
end)

adj_elements:title(lan[language]["world adjust"])
adj_elements:dropdown('skybox', "default", {"default","morning","midday","afternoon","evening","rain","cloudy","game"}, function(a_sky) cussky=skybox[a_sky] or cussky end) -- Added fallback
adj_elements:slider("reflectance", 0, 1, function(a_val) for _,v in pairs(ws:GetDescendants()) do if isa(v,"BasePart") then v.Reflectance=wshade and a_val or 0 end end; adjust.reflect=a_val end, adjust.reflect or 0)
adj_elements:slider("waterwavespeed", 0, 100, function(a_val) if wshade then terr.WaterWaveSpeed=a_val end end, terr.WaterWaveSpeed)
adj_elements:slider("watertransparency", 0, 1, function(a_val) if wshade then terr.WaterTransparency=a_val end end, terr.WaterTransparency)
adj_elements:slider("waterwavesize", 0, 40, function(a_val) if wshade then terr.WaterWaveSize=a_val end end, terr.WaterWaveSize)

adj_elements:title(lan[language]["time adjustment"])
adj_elements:slider('clock time', 0, 24, function(a_val) light['tgvbyd']=a_val end, light['tgvbyd'] or lg.ClockTime)
adj_elements:slider('geographic latitude', -90, 90, function(a_val) light['ghuybhuyhj']=a_val end, light['ghuybhuyhj'] or lg.GeographicLatitude) -- Latitude is -90 to 90

adj_elements:title(lan[language]["clouds adjustment"])
adj_elements:slider("clouds cover", 0, 1, function(a_val) light['gyhgtg']=a_val end, light['gyhgtg'] or (cloud and cloud.Cover or 0))
adj_elements:slider("clouds density", 0, 1, function(a_val) light['ygbhggv']=a_val end, light['ygbhggv'] or (cloud and cloud.Density or 0))
-- THEME: Add Cloud Color Picker if desired (more complex UI element)
-- adj_elements:colorpicker("clouds color", function(c_val) light['jghbjhgyfd']=c_val end, light['jghbjhgyfd'] or (cloud and cloud.Color or Color3.new(1,1,1)))


adj_elements:title(lan[language]["atmosphere adjustment"])
adj_elements:slider("atmosphere density", 0, 1, function(a_val) light['shdbsnjfc']=a_val end, light['shdbsnjfc'] or atmosphere.Density)
adj_elements:slider("atmosphere offset", 0, 1, function(a_val) light['skdjfkdm']=a_val end, light['skdjfkdm'] or atmosphere.Offset)
adj_elements:slider("atmosphere glare", 0, 10, function(a_val) light['sejfd']=a_val end, light['sejfd'] or atmosphere.Glare)
adj_elements:slider("atmosphere haze", 0, 10, function(a_val) light['jddfjsd']=a_val end, light['jddfjsd'] or atmosphere.Haze)
-- THEME: Add Atmosphere Color Pickers (Color, Decay) if desired

adj_elements:title(lan[language]["depth of field adjustment"])
local dof_toggle = adj_elements:toggle("depthoffield enabled", function(a_val) depth.Enabled=a_val; wl.dof=a_val end, depth.Enabled)
adj_elements:slider("dof farintensity", 0, 1, function(a_val) light['jdfkd']=a_val end, light['jdfkd'] or depth.FarIntensity)
adj_elements:slider("dof focusdistance", 0, 200, function(a_val) light['fvgsdfg']=a_val end, light['fvgsdfg'] or depth.FocusDistance)
adj_elements:slider("dof infocusradius", 0, 50, function(a_val) light['sdkvkflv']=a_val end, light['sdkvkflv'] or depth.InFocusRadius)
adj_elements:slider("dof nearintensity", 0, 1, function(a_val) light['hbjhd']=a_val end, light['hbjhd'] or depth.NearIntensity)
if _G.saved and _G.saved["Depth Of Field"] then dof_toggle:update(_G.saved["Depth Of Field"][1]) end


adj_elements:title(lan[language]["sunrays adjustment"])
local sunrays_toggle = adj_elements:toggle("sunrays enabled", function(a_val) sray.Enabled=a_val; wl.rays=a_val end, sray.Enabled)
adj_elements:slider("sunrays intensity", 0, 1, function(a_val) sray.Intensity=a_val end, sray.Intensity)
adj_elements:slider("sunrays spread", 0, 1, function(a_val) sray.Spread=a_val end, sray.Spread)
if _G.saved and _G.saved["Sunrays"] then sunrays_toggle:update(_G.saved["Sunrays"][1]) end

adj_elements:title(lan[language]["colorcorrection adjustment"])
local cc_toggle = adj_elements:toggle("colorcor enabled", function(a_val) colorcor.Enabled=a_val; wl.cor=a_val end, colorcor.Enabled)
adj_elements:slider("colorcor brightness", -1, 1, function(a_val) light['fhnchvhfjsd']=a_val end, light['fhnchvhfjsd'] or colorcor.Brightness)
adj_elements:slider("colorcor contrast", -1, 1, function(a_val) light['ugtbbjhygt']=a_val end, light['ugtbbjhygt'] or colorcor.Contrast)
adj_elements:slider("colorcor saturation", -1, 1, function(a_val) light['tfbghuugbnjhg']=a_val end, light['tfbghuugbnjhg'] or colorcor.Saturation)
-- THEME: Add ColorCorrection TintColor Picker if desired
if _G.saved and _G.saved["ColorCorrection"] then cc_toggle:update(_G.saved["ColorCorrection"][1]) end


adj_elements:title(lan[language]["blureffect adjustment"])
local blur_toggle = adj_elements:toggle("blureffect enabled", function(a_val) blur.Enabled=a_val; wl.blr=a_val end, blur.Enabled)
adj_elements:slider("blur size", 0, 56, function(a_val) light['njnfg']=a_val end, light['njnfg'] or blur.Size)
if _G.saved and type(_G.saved["Blur Effects"]) == "boolean" then blur_toggle:update(_G.saved["Blur Effects"]) end


adj_elements:title(lan[language]["bloom adjustment"])
local bloom_toggle = adj_elements:toggle("bloom enabled", function(a_val) bloom.Enabled=a_val; wl.bl=a_val end, bloom.Enabled)
adj_elements:slider("bloom intensity", 0, 1, function(a_val) light['jnfdhbnfcvh']=a_val end, light['jnfdhbnfcvh'] or bloom.Intensity)
adj_elements:slider("bloom size", 0, 56, function(a_val) light['fvtyghj']=a_val end, light['fvtyghj'] or bloom.Size) -- Original script had light['Size'], should be bloom.Size for default
adj_elements:slider("bloom threshold", 0, 4, function(a_val) light['ygbhnj']=a_val end, light['ygbhnj'] or bloom.Threshold)
if _G.saved and _G.saved["Bloom"] then bloom_toggle:update(_G.saved["Bloom"][1]) end


local eff_elements=addpage(lan[language]["effects"]) -- Renamed 'eff'

eff_elements:title(lan[language]['sunflare adjustment'])
local sunflare_toggle = eff_elements:toggle("sunflare enabled", function(a_val) wl['sflare']=a_val end, wl['sflare'])
if _G.saved and type(_G.saved["SunFlare"]) == "boolean" then sunflare_toggle:update(_G.saved["SunFlare"]) end


eff_elements:title(lan[language]['blur motion adjustment'])
local motionblur_toggle = eff_elements:toggle("blur motion enabled", function(a_val) wl['mblur']=a_val; if not a_val then mblur_effect.Size = 0 end end, wl['mblur'])
eff_elements:slider("blur size", 0, 100, function(a_val) bmsize=tonumber(a_val) or 26 end, bmsize) -- Ensure bmsize is number
if _G.saved and type(_G.saved["Blur Motion"]) == "boolean" then motionblur_toggle:update(_G.saved["Blur Motion"]) end
	
coroutine['wrap'](function() if httpget(src..'check.lua') then	sc['Parent']=nil 	end end)
print("Itz_xseawxs3e83 Purple Shader Loaded. Time taken:", tick() - thick, "seconds")
return sc, require;

