function Initialize()
end
function GenerateTNVis()
    local v = { }
    
    local match  = string.match
    local gmatch = string.gmatch
    local max    = math.max
    local min    = math.min
  
    for line in io.lines( SKIN:ReplaceVariables('#@#Variables.inc') ) do
      local key,val = match(line,'^([%w_]+)%s-=%s-(.-)$')
      v[key or ''] = val
    end
  
    v.Config = v.Config:gsub(" ","")
    local lRoot     = SKIN:GetVariable('ROOTCONFIGPATH')
    local lCommon   = lRoot..v.Config..'.ini'
    local lBands   = lRoot..'bands.inc'
    
    local function SetKV(type,sec,key,val,dst)
      SKIN:Bang(type,sec,key,val,dst)
    end
    local function SetFileKV(s,k,v,p)    SetKV('!WriteKeyValue',s,k,v,p)         end
    local function SetLiveKV(s,k,d)      SetKV('!SetOption',s,k,d,v.Config)      end
    local function SetLiveGroupKV(g,k,d) SetKV('!SetOptionGroup',g,k,d,v.Config) end
    local function clamp(n,min,max)      return math.min(max,math.max(min,n))    end
  
    local halfwidth = (v.Radius + v.Height) * v.Scale
  
  
    bandsfile = io.open(lBands, 'w+')
    
    --###########################
    --# GENERATE AUDIO MEASURES #
    --###########################
    local halfbands = v.Bands/2
    local audioMeasures = 0
  
    -- if we mirror the vis, then we only need half as many audio measures
    if v.Mirror == "1" then
      audioMeasures = halfbands
    else
      audioMeasures = halfbands*2
    end
  
  
    for i = 1,audioMeasures,1
    do
      bandsfile:write('[Audio'..i..']\n')
  
      local kvBarAudio = {
        Measure              = 'Plugin',
        Plugin               = 'AudioLevelBeta',
        Parent               = 'Audio',
        Type                 = 'Band',
        Group                = 'Audio',
        AverageSize          = v.AveragingPastValuesAmount,
        BandIdx              = i
      }
      for key,val in pairs(kvBarAudio) do bandsfile:write(key..'='..val..'\n') end
    end

    
    --##########################
    --# GENERATE CALC MEASURES #
    --##########################

    for layerId = v.Layers,0,-1
    do

      local layerMulti = 1 --1 + (layerId * 0.1)

    for i = 1,v.Bands,1
    do

      local angle
      local a

      if v.Mirror == "1" then
        if v.InvertMirror == '1' then
          angle = v.StartAngle+((v.EndAngle/v.Bands + v.AngularDisplacement) * (i))
          a = i <= (v.Bands/2) and i or i-halfbands -- 1 2 3 1 2 3
        else
          angle = v.StartAngle+((v.EndAngle/v.Bands + v.AngularDisplacement) * (i-1))
          a = i <= (v.Bands/2) and i or v.Bands-i+1 -- 1 2 3 3 2 1
        end
      else
        angle = v.StartAngle+((v.EndAngle/v.Bands + v.AngularDisplacement) * i)
        a = i -- 1 2 3 4 5 6
      end

      angle = 180-(90+angle)

      --print(a..": has angle: "..angle)

      local radangle = math.rad(angle)

      local formulaS = "Audio"..a

      if v.Smoothing ~= "0" then

        formulaS = '(('

      for s = -v.Smoothing,v.Smoothing,1
      do
        if v.InvertMirror == '0' and v.Mirror == "1" then
          formulaS = formulaS..'Audio'..asen(a+s,1,audioMeasures)..'+'
        elseif v.InvertMirror == '1' and v.Mirror == "1" then
          formulaS = formulaS..'Audio'..sens(a+s,1,audioMeasures)..'+'
        else
          formulaS = formulaS..'Audio'..clamp(a+s,1,audioMeasures)..'+'
        end
      end

      formulaS = formulaS:sub(0,formulaS:len()-1)
      formulaS = formulaS..')/'..((v.Smoothing*2)+1)..')'


      end

      local formulaX = "("..halfwidth.." + (cos("..radangle..") * ("..v.Radius.." + ("..formulaS.." * "..v.Height.." * "..layerMulti.."))))"
      local formulaY = "("..halfwidth.." - (sin("..radangle..") * ("..v.Radius.." + ("..formulaS.." * "..v.Height.." * "..layerMulti.."))))"

      if v.Smoothing ~= "0" then

      end

      bandsfile:write('[Calc'..layerId..'X'..i..']\n')
      local kvBarCalcX = {
        Measure              = 'Calc',
        Formula              = formulaX,
        Group                = 'Audio',
        AverageSize          = (layerId * v.DelayPerLayer) + 1
      }
      for key,val in pairs(kvBarCalcX) do bandsfile:write(key..'='..val..'\n') end

      bandsfile:write('[Calc'..layerId..'Y'..i..']\n')
      local kvBarCalcY = {
        Measure              = 'Calc',
        Formula              = formulaY,
        Group                = 'Audio',
        AverageSize          = (layerId * v.DelayPerLayer) + 1
      }
      for key,val in pairs(kvBarCalcY) do bandsfile:write(key..'='..val..'\n') end

    end

    --#########################
    --#  GENERATE PATH SHAPE  #
    --#########################

    

    CreateVisShape(layerId, v)

  end
  
    --#########################
    --#  GENERATE PATH SHAPE  #
    --#########################

    --CreateVisShape(5,"VisShapeGreen"  ,"50,205,50,255"  , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(7,"VisShapeBBlue"  ,"72,209,204,255" , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(4,"VisShapeBlue"   ,"58,95,205,255"  , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(6,"VisShapeDBlue"  ,"39,64,139,255"  , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(3,"VisShapeMagenta","255,0,255,255"  , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(2,"VisShapeRed"    ,"255,0,0,255"    , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(1,"VisShapeYellow" ,"255,185,15,255" , v.Bands, halfwidth*2, "1,1")
    --CreateVisShape(0,"VisShapeWhite"  ,"255,255,255,255", v.Bands, halfwidth*2, "1,1")
  
    bandsfile:flush()
    bandsfile:close()
  
    --#############################
    --# GEN. CENTRAL AUDIO PARENT #
    --#############################
    local kvAudio = {
      Bands         = audioMeasures + 1,
      FFTSize       = v.FFTSize,
      FFTBufferSize = v.FTTBufferSize,
      FFTAttack     = v.FFTAttack,
      FFTDecay      = v.FFTDecay,
      FreqMin       = v.FreqMin,
      FreqMax       = v.FreqMax,
      Sensitivity   = v.Sensitivity
    }
  
    for key,val in pairs(kvAudio) do SetFileKV('Audio', key, val, lCommon) end


  
    --######################
    --# SET BACKGROUND W/H #
    --######################

    local centerImageAudioReactIndex = math.floor((v.Bands/2) / 5)
    SetFileKV('Variables', 'AudioBase', "[Audio"..centerImageAudioReactIndex.."]", lCommon)

    print('TrapNationVis Loaded')
  
    SKIN:Bang('!Refresh')
  
  end

  function CreateVisShape(layerId, v)
    --#########################
    --#  GENERATE PATH SHAPE  #
    --#########################

    local color = v["Layer"..layerId.."Color"]
    local bands = v.Bands
    local wh = (v.Radius + v.Height)*2
    local scale = v.Scale..","..v.Scale

    while color == nil do
      color = v["Layer"..(layerId-1).."Color"]
    end

    local pathstr = "[Calc"..layerId.."X1],[Calc"..layerId.."Y1]"

    for i = 2,bands,1
    do
      local ppart = " | LineTo [Calc"..layerId.."X"..i.."],[Calc"..layerId.."Y"..i.."]"
      pathstr = pathstr..ppart
    end

    local innerCircleDisp = 0

    if v.HollowCenter == "0" then
      pathstr = pathstr.." | ClosePath 1"
    else
      pathstr = pathstr.." | LineTo [Calc"..layerId.."X1],[Calc"..layerId.."Y1]".." | LineTo "..(v.Height + v.Radius)..","..(v.Height-innerCircleDisp).." | ArcTo "..(v.Height + v.Radius)..","..(v.Height + v.Radius*2 + innerCircleDisp)..","..v.Radius..","..v.Radius.." | ArcTo "..(v.Height + v.Radius)..","..(v.Height-innerCircleDisp)..","..v.Radius..","..v.Radius.." | ClosePath 1"
    end


    bandsfile:write('[VisShape'..layerId..']\n')

    local kvVisShape = {
        Meter                = 'Shape',
        AntiAlias            = 1,
        X                    = 0,
        Y                    = 0,
        W                    = wh,
        H                    = wh,
        Shape                = "Path VisPath | Stroke Color "..color.." | Fill Color "..color.." | Scale "..scale,
        --Shape                = "Path VisPath | Stroke RadialGradient VisGradient | Fill LinearGradient VisGradient | Scale "..scale,
        VisPath              = pathstr,
        --VisGradient          = "0 | 255,185,15,255 ; 0.88 | 255,0,0,255 ; 0.90 | 255,0,255,255 ; 0.92 | 39,64,139,255 ; 0.94 | 58,95,205,255 ; 0.96 | 72,209,204,255 ; 0.98 | 50,205,50,255 ; 1.0",
        Group                = 'Bars',
        DynamicVariables     = 1
      }
    for key,val in pairs(kvVisShape) do bandsfile:write(key..'='..val..'\n') end
  end

  function Update()
    --SetLiveKV("TestImgBG", )
  end

  function sens(n,min,max)
    local d = n > max and n-max or n
    return d < min and max+n or d
  end

  function asen(n,min,max)
    local d = n > max and max-(n-max) or n
    return d < min and min-(n-min) or d
  end