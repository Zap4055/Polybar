[Variables]
Volume_X =316
;Left, Right or Middle
Volume_Anchor=left

[Metadata]
Name=Papirus\\Volume
Author=reddit.com/u/khanhas
Description=Display volume, increase and decrease volume by mouse scroll, click at speaker icon to mute. Click at volume number to activate volume slider and audio device changer.

[VolumeAnchor]
Measure=String
String = #Volume_Anchor#
IfMatch = Center|center|Middle|middle
IfMatchAction = [!SetOption VolumeShape X "(#Bar_OffsetX#+#*Volume_X*#-([*VolumeIcon:W*]+[*Volume:W*]+10)/2)"][!SetOption VolumeIcon X "(#Bar_OffsetX#+#*Volume_X*#-([*VolumeIcon:W*]+[*Volume:W*]+10)/2)"][!SetOption Volume X 10R]
IfMatch2 = Right|right
IfMatchAction2 = [!SetOption VolumeIcon StringAlign RightCenter][!SetOption Volume StringAlign RightCenter][!SetOption VolumeShape X "([*Volume:X*]-[*VolumeIcon:W*]-10)"][!SetOption VolumeIcon X "([*Volume:X*]-10)"][!SetOption Volume X "(#Bar_OffsetX#+#*Volume_X*#)"]

[VolumeShape]
Meter=Shape
X=(#Bar_OffsetX#+#Volume_X#)
Y=(#Bar_OffsetY#+#Bar_Height#/2-#Section_Height#/2)
Shape =Rectangle -20,0,([Volume:W]+[VolumeIcon:W]+10+40),#Section_Height#,5 | StrokeWidth 0 | Fill Color #Color_Scheme1#
Shape2=Rectangle 0,#Section_Height#,([Volume:W]+[VolumeIcon:W]+10),-3,1.5 | StrokeWidth 0 | Fill Color #Color_Scheme3#
DynamicVariables=1
Group=Volume

[VolumeLevel]
Measure=Plugin
Plugin=Win7AudioPlugin
Group=Volume

[VolumeLevelCalc]
Measure=Calc
Formula=VolumeLevel <= 0 ? 0 : VolumeLevel
IfCondition=VolumeLevelCalc = 0
IfTrueAction=[!SetOption VolumeIcon Text ""][!UpdateMeterGroup Volume][!Redraw]
IfCondition2=(VolumeLevelCalc <= 50) && (VolumeLevelCalc > 0)
IfTrueAction2=[!SetOption VolumeIcon Text ""][!UpdateMeterGroup Volume][!Redraw]
IfCondition3=VolumeLevelCalc > 50 
IfTrueAction3=[!SetOption VolumeIcon Text ""][!UpdateMeterGroup Volume][!Redraw]
Group = Volume

[VolumeIcon]
Meter=String
FontFace=FontAwesome
FontSize=(#Font_Size#*16/13)
FontColor=#Color_Scheme2#c0
SolidColor=0,0,0,1
AntiAlias=1
StringAlign=LeftCenter
X=(#Bar_OffsetX#+#Volume_X#)
Y=(#Bar_OffsetY#+#Bar_Height#/2)
LeftMouseUpAction=[!CommandMeasure VolumeLevel "ToggleMute"][!UpdateMeasureGroup Volume]
Group=Volume
DynamicVariables=1

[Volume]
Meter=String
MeasureName=VolumeLevelCalc
Postfix=%
FontFace=#Font_Face2#
FontSize=#Font_Size#
FontColor=#Color_Scheme2#
SolidColor=0,0,0,1
AntiAlias=1
StringAlign=LeftCenter
X=10R
Y=r
MouseScrollDownAction=[!CommandMeasure VolumeLevel "ChangeVolume -5"][!UpdateMeasureGroup Volume][!UpdateMeterGroup Volume][!UpdateMeter VolumeShape][!Redraw]
MouseScrollUpAction  =[!CommandMeasure VolumeLevel "ChangeVolume +5"][!UpdateMeasureGroup Volume][!UpdateMeterGroup Volume][!UpdateMeter VolumeShape][!Redraw]
LeftMouseUpAction =[!WriteKeyValue Variables Curr_X ([Volume:X]+#CURRENTCONFIGX#) "#ROOTCONFIGPATH#\Themes\#Theme#\Additional_Comps_And_Scripts\VolumeControl.ini"][!WriteKeyValue Variables Curr_Y [SubSkinYPositionCalc] "#ROOTCONFIGPATH#\Themes\#Theme#\Additional_Comps_And_Scripts\VolumeControl.ini"][!WriteKeyValue Variables Dir [SubSkinDirectionCalc] "#ROOTCONFIGPATH#\Themes\#Theme#\Additional_Comps_And_Scripts\VolumeControl.ini"][!DeactivateConfig "#ROOTCONFIG#\Themes\#Theme#\Additional_Comps_And_Scripts"][!ToggleConfig "Polybar\Themes\#Theme#\Additional_Comps_And_Scripts" "VolumeControl.ini"]
MouseOverAction=[!CommandMeasure AdditionalSkinActionTimer "Stop 1"]
MouseLeaveAction=[!CommandMeasure AdditionalSkinActionTimer "Execute 1"]
DynamicVariables=1
Group=Volume
