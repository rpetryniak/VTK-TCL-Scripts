package require vtk

set renWin_width 800
set renWin_height 800
set ren1GradientBackground 1
set ren1GradientColor_r 0.5
set ren1GradientColor_g 0.6
set ren1GradientColor_b 0.8

set twoRenderers 0
set viewOption "volume"

set inputFileName data/tooth.vtk
vtkStructuredPointsReader reader
  reader SetFileName $inputFileName
  reader Update
# data in range 0..255
set isoLevel 128
set isoLevel1 100
set isoLevel2 180
set thresh 128

vtkRenderer ren1
vtkRenderWindow renWin
  renWin AddRenderer ren1
vtkRenderWindowInteractor iren
  iren SetRenderWindow renWin

set antique_white "0.9804 0.9216 0.8431"

set opacity  0.5
set color $antique_white

vtkLookupTable lut
  lut SetHueRange 0.66667 0.0
  lut SetSaturationRange 1 1
  lut SetValueRange 1 1
  lut SetAlphaRange 1 1
  lut SetNumberOfColors 256
  lut Build

vtkMarchingCubes iso
  iso SetInput [reader GetOutput]
  iso SetValue 0 $isoLevel

vtkPolyDataMapper mapper
  mapper SetInput [iso GetOutput]
  mapper ScalarVisibilityOn
  mapper SetLookupTable lut
  mapper SetScalarRange 0 255

vtkActor isoActor
  isoActor SetMapper mapper
  #eval [isoActor GetProperty] SetColor $color
  eval [isoActor GetProperty] SetOpacity $opacity
  
ren1 AddActor isoActor


set renWin_width 640
set renWin_height 480
set ren1GradientBackground 0

#ren1 SetBackground $ren1GradientColor_r $ren1GradientColor_g $ren1GradientColor_b
ren1 SetBackground 0.5 0.6 0.8
ren1 SetGradientBackground 0
renWin SetSize $renWin_width $renWin_height
renWin Render

iren AddObserver UserEvent {wm deiconify .vtkInteract}
iren Initialize
wm withdraw .

iren Start

vtkTextActor textActor
  textActor SetDisplayPosition 70 20
  eval [textActor GetTextProperty] SetJustificationToCentered
  eval [textActor GetTextProperty] SetFontSize 18
  ren1 AddActor textActor

vtkWindowToImageFilter w2if
  w2if SetInput renWin

for {set level 0} {$level < 255 } {incr level} {
  textActor SetInput "Iso value: $level"
  iso SetValue 0 $level
  renWin Render
}
