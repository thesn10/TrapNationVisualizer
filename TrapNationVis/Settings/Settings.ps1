Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$v = @{}
$variablesPath = Resolve-Path "..\@Resources\Variables.inc"
$imagesPath = Resolve-Path "..\@Resources\Images\"
$raw = Get-Content -Path $variablesPath
foreach ($line in $raw)
{
    if ($line -match "^(\w+)\s??=\s??(.*?);?\n?$")
    {
        Write-Host $matches[1]:  $matches[2]
        $v[$matches[1]] = $matches[2]
    }
}

if ($v["ImageAlpha"] -eq "")
{
    $v["ImageAlpha"]=255
}

$rmPath = (Get-Process "Rainmeter").Path

$assemblies=(
    "System", 
    "System.Runtime.InteropServices",
    "System.Windows.Forms"
)

$psforms = @'
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace PSForms
{
    public class ListViewX : ListView
    {
        [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)]
        public extern static int SetWindowTheme(IntPtr hWnd, string pszSubAppName, string pszSubIdList);

        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            SetWindowTheme(this.Handle, "explorer", null);
        }
    }

    // [WIP]
    public class NumericUpDownX : NumericUpDown
    {
        [DllImport("uxtheme.dll", CharSet = CharSet.Unicode)]
        public extern static int SetWindowTheme(IntPtr hWnd, string pszSubAppName, string pszSubIdList);

        public NumericUpDownX()
        {
            this.Paint += NumericUpDownX_Paint;
            this.GotFocus += NumericUpDownX_GotFocus;
            this.LostFocus += NumericUpDownX_LostFocus;
        }

        public string Unit { get; set; }

        protected override void OnHandleCreated(EventArgs e)
        {
            base.OnHandleCreated(e);
            SetWindowTheme(this.Handle, "explorer", null);
        }

        private void NumericUpDownX_Paint(object sender, PaintEventArgs e)
        {
            //this.Text = this.Value + Unit;
        }

        private void NumericUpDownX_GotFocus(object sender, EventArgs e)
        {
            //this.Text = this.Value.ToString();
        }

        private void NumericUpDownX_LostFocus(object sender, EventArgs e)
        {
            //this.Text = this.Value + Unit;
        }

        /*
        protected override void UpdateEditText()
        {
            // Append the units to the end of the numeric value
            //this.Text = this.Value + Unit;
        }*/
    }
}
'@

$wppsdef = @'
[DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool WritePrivateProfileString(string lpAppName,
   string lpKeyName,
   string lpString,
   string lpFileName);
'@

$wpps = Add-Type -MemberDefinition $wppsdef -Name WinWritePrivateProfileString -Namespace Win32Utils -PassThru
Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $psforms -Language CSharp

function ToRMColor([System.Drawing.Color] $color)
{
    $colorR = [int]$color.R
    $colorG = [int]$color.G
    $colorB = [int]$color.B
    $colorA = [int]$color.A
    return "$colorR,$colorG,$colorB,$colorA"
}

function ToSDColor([string] $color)
{
    $colors = $color.Split(',')
    return [System.Drawing.Color]::FromArgb($colors[3], $colors[0], $colors[1], $colors[2])
}

$form                            = New-Object system.Windows.Forms.Form
$form.ClientSize                 = '795,440'
$form.text                       = $v["Config"]
$form.TopMost                    = $false
$form.Icon                       = [Drawing.Icon]::ExtractAssociatedIcon($rmPath)
$form.AutoSize                   = $false
$form.FormBorderStyle            = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.ShowInTaskbar              = $false
$form.MinimizeBox                = $false
$form.MaximizeBox                = $false
$form.Add_Closing({ formClosing })

$gbGeneral                       = New-Object system.Windows.Forms.Groupbox
$gbGeneral.height                = 170
$gbGeneral.width                 = 250
$gbGeneral.text                  = "General"
$gbGeneral.location              = New-Object System.Drawing.Point(10,10)

$gbBar                           = New-Object system.Windows.Forms.Groupbox
$gbBar.height                    = 110
$gbBar.width                     = 250
$gbBar.text                      = "Circle"
$gbBar.location                  = New-Object System.Drawing.Point(10,190)

$gbLayers                        = New-Object system.Windows.Forms.Groupbox
$gbLayers.height                 = 220
$gbLayers.width                  = 250
$gbLayers.text                   = "Layers"
$gbLayers.location               = New-Object System.Drawing.Point(530,10)

$numRadius                       = New-Object PSForms.NumericUpDownX
$numRadius.width                 = 100
$numRadius.height                = 20
$numRadius.location              = New-Object System.Drawing.Point(140,15)
$numRadius.Font                  = 'Microsoft Sans Serif,8'
$numRadius.Minimum               = 0
$numRadius.Maximum               = 1000
$numRadius.Value                 = $v["Radius"]
$numRadius.Unit                  = " px"

$lblRadius                       = New-Object system.Windows.Forms.Label
$lblRadius.text                  = "Radius"
$lblRadius.AutoSize              = $true
$lblRadius.width                 = 25
$lblRadius.height                = 10
$lblRadius.location              = New-Object System.Drawing.Point(10,20)
$lblRadius.Font                  = 'Microsoft Sans Serif,8'

$lblHeight                       = New-Object system.Windows.Forms.Label
$lblHeight.text                  = "Height"
$lblHeight.AutoSize              = $true
$lblHeight.width                 = 25
$lblHeight.height                = 10
$lblHeight.location              = New-Object System.Drawing.Point(10,50)
$lblHeight.Font                  = 'Microsoft Sans Serif,8'

$lblStartAngle                   = New-Object system.Windows.Forms.Label
$lblStartAngle.text              = "Start angle"
$lblStartAngle.AutoSize          = $true
$lblStartAngle.width             = 25
$lblStartAngle.height            = 10
$lblStartAngle.location          = New-Object System.Drawing.Point(10,80)
$lblStartAngle.Font              = 'Microsoft Sans Serif,8'

$lblEndAngle                     = New-Object system.Windows.Forms.Label
$lblEndAngle.text                = "End angle"
$lblEndAngle.AutoSize            = $true
$lblEndAngle.width               = 25
$lblEndAngle.height              = 10
$lblEndAngle.location            = New-Object System.Drawing.Point(10,110)
$lblEndAngle.Font                = 'Microsoft Sans Serif,8'

$lblBarAmount                    = New-Object system.Windows.Forms.Label
$lblBarAmount.text               = "Circle Measures"
$lblBarAmount.AutoSize           = $true
$lblBarAmount.width              = 25
$lblBarAmount.height             = 10
$lblBarAmount.location           = New-Object System.Drawing.Point(10,20)
$lblBarAmount.Font               = 'Microsoft Sans Serif,8'

$cbHollowCenter                  = New-Object system.Windows.Forms.CheckBox
$cbHollowCenter.text             = "Hollow Center"
$cbHollowCenter.AutoSize         = $false
$cbHollowCenter.width            = 95
$cbHollowCenter.height           = 20
$cbHollowCenter.location         = New-Object System.Drawing.Point(10,45)
$cbHollowCenter.Font             = 'Microsoft Sans Serif,8'
$cbHollowCenter.Checked          = [int]$v["HollowCenter"]

$lblBarWidth                     = New-Object system.Windows.Forms.Label
$lblBarWidth.text                = "Reserved [WIP]"
$lblBarWidth.AutoSize            = $true
$lblBarWidth.width               = 25
$lblBarWidth.height              = 10
$lblBarWidth.location            = New-Object System.Drawing.Point(10,80)
$lblBarWidth.Font                = 'Microsoft Sans Serif,8'
$lblBarWidth.Enabled             = $false

$gbSmoothing                     = New-Object system.Windows.Forms.Groupbox
$gbSmoothing.height              = 80
$gbSmoothing.width               = 250
$gbSmoothing.text                = "Smoothing"
$gbSmoothing.location            = New-Object System.Drawing.Point(270,10)

$gbVisualization                 = New-Object system.Windows.Forms.Groupbox
$gbVisualization.height          = 170
$gbVisualization.width           = 250
$gbVisualization.text            = "Visualization"
$gbVisualization.location        = New-Object System.Drawing.Point(270,100)

$gbMirror                        = New-Object system.Windows.Forms.Groupbox
$gbMirror.height                 = 80
$gbMirror.width                  = 250
$gbMirror.text                   = "Mirror"
$gbMirror.location               = New-Object System.Drawing.Point(10,310)

$lblSmoothing                    = New-Object system.Windows.Forms.Label
$lblSmoothing.text               = "Smoothing"
$lblSmoothing.AutoSize           = $true
$lblSmoothing.width              = 25
$lblSmoothing.height             = 10
$lblSmoothing.location           = New-Object System.Drawing.Point(10,20)
$lblSmoothing.Font               = 'Microsoft Sans Serif,8'

$lblPastValueAveraging           = New-Object system.Windows.Forms.Label
$lblPastValueAveraging.text      = "Reserved [WIP]"
$lblPastValueAveraging.AutoSize  = $true
$lblPastValueAveraging.width     = 25
$lblPastValueAveraging.height    = 10
$lblPastValueAveraging.location  = New-Object System.Drawing.Point(10,50)
$lblPastValueAveraging.Font      = 'Microsoft Sans Serif,8'
$lblPastValueAveraging.Enabled   = $false

$lblFFTSize                      = New-Object system.Windows.Forms.Label
$lblFFTSize.text                 = "FFTSize"
$lblFFTSize.AutoSize             = $true
$lblFFTSize.width                = 25
$lblFFTSize.height               = 10
$lblFFTSize.location             = New-Object System.Drawing.Point(10,20)
$lblFFTSize.Font                 = 'Microsoft Sans Serif,8'

$lblFFTBufferSize                = New-Object system.Windows.Forms.Label
$lblFFTBufferSize.text           = "FFTBufferSize"
$lblFFTBufferSize.AutoSize       = $true
$lblFFTBufferSize.width          = 25
$lblFFTBufferSize.height         = 10
$lblFFTBufferSize.location       = New-Object System.Drawing.Point(10,50)
$lblFFTBufferSize.Font           = 'Microsoft Sans Serif,8'

$lblFFTAttack                    = New-Object system.Windows.Forms.Label
$lblFFTAttack.text               = "Attack"
$lblFFTAttack.AutoSize           = $true
$lblFFTAttack.width              = 25
$lblFFTAttack.height             = 10
$lblFFTAttack.location           = New-Object System.Drawing.Point(10,80)
$lblFFTAttack.Font               = 'Microsoft Sans Serif,8'

$lblFFTDecay                     = New-Object system.Windows.Forms.Label
$lblFFTDecay.text                = "Decay"
$lblFFTDecay.AutoSize            = $true
$lblFFTDecay.width               = 25
$lblFFTDecay.height              = 10
$lblFFTDecay.location            = New-Object System.Drawing.Point(10,110)
$lblFFTDecay.Font                = 'Microsoft Sans Serif,8'

$cbMirror                        = New-Object system.Windows.Forms.CheckBox
$cbMirror.text                   = "Mirror"
$cbMirror.AutoSize               = $false
$cbMirror.width                  = 95
$cbMirror.height                 = 20
$cbMirror.location               = New-Object System.Drawing.Point(10,20)
$cbMirror.Font                   = 'Microsoft Sans Serif,8'
$cbMirror.Checked                = [int]$v["Mirror"]

$cbInvertMirror                  = New-Object system.Windows.Forms.CheckBox
$cbInvertMirror.text             = "Invert Mirror"
$cbInvertMirror.AutoSize         = $false
$cbInvertMirror.width            = 95
$cbInvertMirror.height           = 20
$cbInvertMirror.location         = New-Object System.Drawing.Point(10,50)
$cbInvertMirror.Font             = 'Microsoft Sans Serif,8'
$cbInvertMirror.Checked          = [int]$v["InvertMirror"]
$cbInvertMirror.Enabled          = [int]$v["Mirror"]

$gbFrequency                     = New-Object system.Windows.Forms.Groupbox
$gbFrequency.height              = 110
$gbFrequency.width               = 250
$gbFrequency.text                = "Freqency"
$gbFrequency.location            = New-Object System.Drawing.Point(270,280)

$lblStartFreqency                = New-Object system.Windows.Forms.Label
$lblStartFreqency.text           = "Start Freqency"
$lblStartFreqency.AutoSize       = $true
$lblStartFreqency.width          = 25
$lblStartFreqency.height         = 10
$lblStartFreqency.location       = New-Object System.Drawing.Point(10,50)
$lblStartFreqency.Font           = 'Microsoft Sans Serif,8'

$lblEndFreqency                  = New-Object system.Windows.Forms.Label
$lblEndFreqency.text             = "End Freqency"
$lblEndFreqency.AutoSize         = $true
$lblEndFreqency.width            = 25
$lblEndFreqency.height           = 10
$lblEndFreqency.location         = New-Object System.Drawing.Point(10,80)
$lblEndFreqency.Font             = 'Microsoft Sans Serif,8'

$lblAngularDisplacement          = New-Object system.Windows.Forms.Label
$lblAngularDisplacement.text     = "Angle displacement"
$lblAngularDisplacement.AutoSize = $true
$lblAngularDisplacement.width    = 25
$lblAngularDisplacement.height   = 10
$lblAngularDisplacement.location = New-Object System.Drawing.Point(10,140)
$lblAngularDisplacement.Font     = 'Microsoft Sans Serif,8'

$lblPresets                      = New-Object system.Windows.Forms.Label
$lblPresets.text                 = "Presets"
$lblPresets.AutoSize             = $true
$lblPresets.width                = 25
$lblPresets.height               = 10
$lblPresets.location             = New-Object System.Drawing.Point(10,20)
$lblPresets.Font                 = 'Microsoft Sans Serif,8'

$lblSensitivity                  = New-Object system.Windows.Forms.Label
$lblSensitivity.text             = "Sensitivity"
$lblSensitivity.AutoSize         = $true
$lblSensitivity.width            = 25
$lblSensitivity.height           = 10
$lblSensitivity.location         = New-Object System.Drawing.Point(10,140)
$lblSensitivity.Font             = 'Microsoft Sans Serif,8'

$numHeight                       = New-Object PSForms.NumericUpDownX
$numHeight.width                 = 100
$numHeight.height                = 20
$numHeight.location              = New-Object System.Drawing.Point(140,45)
$numHeight.Font                  = 'Microsoft Sans Serif,8'
$numHeight.Minimum               = 0
$numHeight.Maximum               = 360
$numHeight.Value                 = $v["Height"]
$numHeight.Unit                  = " px"

$numStartAngle                   = New-Object PSForms.NumericUpDownX
$numStartAngle.width             = 100
$numStartAngle.height            = 20
$numStartAngle.location          = New-Object System.Drawing.Point(140,75)
$numStartAngle.Font              = 'Microsoft Sans Serif,8'
$numStartAngle.Minimum           = 0
$numStartAngle.Maximum           = 360
$numStartAngle.Value             = $v["StartAngle"]
$numStartAngle.Unit              = " deg"

$numEndAngle                     = New-Object PSForms.NumericUpDownX
$numEndAngle.width               = 100
$numEndAngle.height              = 20
$numEndAngle.location            = New-Object System.Drawing.Point(140,105)
$numEndAngle.Font                = 'Microsoft Sans Serif,8'
$numEndAngle.Minimum             = 0
$numEndAngle.Maximum             = 360
$numEndAngle.Value               = $v["EndAngle"]
$numEndAngle.Unit                = " deg"

$numAngularDisplacement          = New-Object PSForms.NumericUpDownX
$numAngularDisplacement.width    = 100
$numAngularDisplacement.height   = 20
$numAngularDisplacement.location  = New-Object System.Drawing.Point(140,135)
$numAngularDisplacement.Font     = 'Microsoft Sans Serif,8'
$numAngularDisplacement.Minimum  = 0
$numAngularDisplacement.Maximum  = 360
$numAngularDisplacement.Value    = $v["AngularDisplacement"]
$numAngularDisplacement.Unit     = '°'

$numBars                         = New-Object PSForms.NumericUpDownX
$numBars.width                   = 100
$numBars.height                  = 20
$numBars.location                = New-Object System.Drawing.Point(140,15)
$numBars.Font                    = 'Microsoft Sans Serif,8'
$numBars.Minimum                 = 0
$numBars.Maximum                 = 2000
$numBars.Value                   = $v["Bands"]

$numBarWidth                     = New-Object PSForms.NumericUpDownX
$numBarWidth.width               = 100
$numBarWidth.height              = 20
$numBarWidth.location            = New-Object System.Drawing.Point(140,75)
$numBarWidth.Font                = 'Microsoft Sans Serif,8'
$numBarWidth.Minimum             = 1
$numBarWidth.Maximum             = 100
$numBarWidth.Value               = 1
$numBarWidth.Enabled             = $false

$numFFTAttack                    = New-Object PSForms.NumericUpDownX
$numFFTAttack.width              = 100
$numFFTAttack.height             = 20
$numFFTAttack.location           = New-Object System.Drawing.Point(140,75)
$numFFTAttack.Font               = 'Microsoft Sans Serif,8'
$numFFTAttack.Minimum            = 0
$numFFTAttack.Maximum            = 1000
$numFFTAttack.Value              = $v["FFTAttack"]

$numFFTDecay                     = New-Object PSForms.NumericUpDownX
$numFFTDecay.width               = 100
$numFFTDecay.height              = 20
$numFFTDecay.location            = New-Object System.Drawing.Point(140,105)
$numFFTDecay.Font                = 'Microsoft Sans Serif,8'
$numFFTDecay.Minimum             = 0
$numFFTDecay.Maximum             = 1000
$numFFTDecay.Value               = $v["FFTDecay"]

$cbFFTSize                       = New-Object System.Windows.Forms.ComboBox
$cbFFTSize.width                 = 100
$cbFFTSize.height                = 20
$cbFFTSize.location              = New-Object System.Drawing.Point(140,15)
$cbFFTSize.Font                  = 'Microsoft Sans Serif,8'
$cbFFTSize.DropDownStyle         = 'DropDownList'
$cbFFTSize.Items.AddRange(@(512,1024,2048,4096,8192))
$cbFFTSize.SelectedIndex         = [Math]::Round([Math]::Log($v["FFTSize"], 2)-9)

$cbFFTBufferSize                 = New-Object System.Windows.Forms.ComboBox
$cbFFTBufferSize.width           = 100
$cbFFTBufferSize.height          = 20
$cbFFTBufferSize.location        = New-Object System.Drawing.Point(140,45)
$cbFFTBufferSize.Font            = 'Microsoft Sans Serif,8'
$cbFFTBufferSize.DropDownStyle   = 'DropDownList'
$cbFFTBufferSize.Items.AddRange(@(4096,8192,16384,32768))
$cbFFTBufferSize.SelectedIndex   = [Math]::Round([Math]::Log($v["FFTBufferSize"], 2)-12)

$numSensitivity                  = New-Object PSForms.NumericUpDownX
$numSensitivity.width            = 100
$numSensitivity.height           = 20
$numSensitivity.location         = New-Object System.Drawing.Point(140,135)
$numSensitivity.Font             = 'Microsoft Sans Serif,8'
$numSensitivity.Minimum          = 0
$numSensitivity.Maximum          = 100
$numSensitivity.Value            = $v["Sensitivity"]
$numSensitivity.Unit             = " dB"

$numFreqMin                      = New-Object PSForms.NumericUpDownX
$numFreqMin.width                = 100
$numFreqMin.height               = 20
$numFreqMin.location             = New-Object System.Drawing.Point(140,45)
$numFreqMin.Font                 = 'Microsoft Sans Serif,8'
$numFreqMin.Minimum              = 20
$numFreqMin.Maximum              = 20000
$numFreqMin.Value                = $v["FreqMin"]
$numFreqMin.Unit                 = " hz"

$numFreqMax                      = New-Object PSForms.NumericUpDownX
$numFreqMax.width                = 100
$numFreqMax.height               = 20
$numFreqMax.location             = New-Object System.Drawing.Point(140,75)
$numFreqMax.Font                 = 'Microsoft Sans Serif,8'
$numFreqMax.Minimum              = 20
$numFreqMax.Maximum              = 20000
$numFreqMax.Value                = $v["FreqMax"]
$numFreqMax.Unit                 = " hz"

$numSmoothing                    = New-Object PSForms.NumericUpDownX
$numSmoothing.width              = 100
$numSmoothing.height             = 20
$numSmoothing.location           = New-Object System.Drawing.Point(140,15)
$numSmoothing.Font               = 'Microsoft Sans Serif,8'
$numSmoothing.Minimum            = 0
$numSmoothing.Maximum            = 10
$numSmoothing.Value              = $v["Smoothing"]

$numPastValueAvg                 = New-Object PSForms.NumericUpDownX
$numPastValueAvg.width           = 100
$numPastValueAvg.height          = 20
$numPastValueAvg.location        = New-Object System.Drawing.Point(140,45)
$numPastValueAvg.Font            = 'Microsoft Sans Serif,8'
$numPastValueAvg.Minimum         = 1
$numPastValueAvg.Maximum         = 10
$numPastValueAvg.Value           = 1
$numPastValueAvg.Enabled         = $false

$lblLayers                       = New-Object system.Windows.Forms.Label
$lblLayers.text                  = "Delay per layer"
$lblLayers.AutoSize              = $true
$lblLayers.width                 = 25
$lblLayers.height                = 10
$lblLayers.location              = New-Object System.Drawing.Point(10,20)

$numLayers                       = New-Object PSForms.NumericUpDownX
$numLayers.width                 = 100
$numLayers.height                = 20
$numLayers.location              = New-Object System.Drawing.Point(140,15)
$numLayers.Font                  = 'Microsoft Sans Serif,8'
$numLayers.Minimum               = 0
$numLayers.Maximum               = 10
$numLayers.Value                 = $v["DelayPerLayer"]


$tableLayers                     = New-Object PSForms.ListViewX
$tableLayers.location            = '10,40'
$tableLayers.View                = [System.Windows.Forms.View]::Details
$tableLayers.Size                = '230,130'
$tableLayers.Sorting             = [System.Windows.Forms.SortOrder]::Ascending
$tableLayers.FullRowSelect       = $true
$column1 = $tableLayers.Columns.Add("Layer",50)
$column2 = $tableLayers.Columns.Add("Color",170)
$tableLayers.Add_MouseDoubleClick({ tableLayersItemClicked })

foreach ($key in $v.Keys)
{
    if ($key.StartsWith("Layer") -and $key.EndsWith("Color"))
    {
        $layerid = $key.Substring(5,1)

        $lwitem = New-Object System.Windows.Forms.ListViewItem
        $lwitem.Text = $layerid
        $lwitem.Name = $layerid
        #$lwitem.BackColor = ToSDColor $v[$key]
        $lwitem.UseItemStyleForSubItems = $false

        $lwsubitem = New-Object System.Windows.Forms.ListViewItem+ListViewSubItem
        $lwsubitem.BackColor = ToSDColor $v[$key]
        $dummy = $lwitem.SubItems.Add($lwsubitem)

        $dummy = $tableLayers.Items.Add($lwitem)

    }
}

#$testgb = New-Object System.Windows.Forms.GroupBox -Property @{
#    Height   = 140
#    Width    = 250
#    Text     = "General"
#    Location = New-Object System.Drawing.Point(10,10)
#}

#$testgb.Controls.AddRange(@(
#    New-Object system.Windows.Forms.Label -Property @{
#        Text                  = "Radius"
#        AutoSize              = $true
#        Width                 = 25
#        Height                = 10
#        Location              = New-Object System.Drawing.Point(10,20)
#    }
#))

$btnAddLayer                     = New-Object system.Windows.Forms.Button
$btnAddLayer.text                = "Add Layer"
$btnAddLayer.width               = 110
$btnAddLayer.height              = 30
$btnAddLayer.location            = New-Object System.Drawing.Point(10,180)
$btnAddLayer.Font                = 'Microsoft Sans Serif,8'

$btnDeleteLayer                  = New-Object system.Windows.Forms.Button
$btnDeleteLayer.text             = "Delete Layer"
$btnDeleteLayer.width            = 110
$btnDeleteLayer.height           = 30
$btnDeleteLayer.location         = New-Object System.Drawing.Point(130,180)
$btnDeleteLayer.Font             = 'Microsoft Sans Serif,8'

$gbImage                         = New-Object system.Windows.Forms.Groupbox
$gbImage.height                  = 150
$gbImage.width                   = 250
$gbImage.text                    = "Image"
$gbImage.location                = New-Object System.Drawing.Point(530,240)

$txtImageName                    = New-Object system.Windows.Forms.TextBox
$txtImageName.text               = $v["ImageName"]
$txtImageName.AutoSize           = $true
$txtImageName.width              = 80
$txtImageName.height             = 10
$txtImageName.location           = New-Object System.Drawing.Point(10,20)
$txtImageName.Enabled            = $false

$imgName                         = $v["ImageName"]
$imgPath                         = Resolve-Path "..\@Resources\Images\$imgName"
Write-Host $imgPath
$img                             = [System.Drawing.Image]::Fromfile($imgPath)
$pictureBox                      = New-object Windows.Forms.PictureBox
$pictureBox.Width                = 100
$pictureBox.Height               = 100
$pictureBox.Image                = $img
$pictureBox.location             = New-Object System.Drawing.Point(140,20)
$pictureBox.SizeMode             = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$pictureBox.BorderStyle          = "Fixed3D"

$btnSelectImage                  = New-Object system.Windows.Forms.Button
$btnSelectImage.Text             = "Select"
$btnSelectImage.width            = 50
$btnSelectImage.height           = 20
$btnSelectImage.location         = New-Object System.Drawing.Point(90,20)
$btnSelectImage.Font             = 'Microsoft Sans Serif,8'

$lblImageAlpha                   = New-Object system.Windows.Forms.Label
$lblImageAlpha.text              = "Image Opacity"
$lblImageAlpha.AutoSize          = $true
$lblImageAlpha.width             = 25
$lblImageAlpha.height            = 10
$lblImageAlpha.location          = New-Object System.Drawing.Point(10,50)

$lblImageSizeX                   = New-Object system.Windows.Forms.Label
$lblImageSizeX.text              = "Image Scale X"
$lblImageSizeX.AutoSize          = $true
$lblImageSizeX.width             = 25
$lblImageSizeX.height            = 10
$lblImageSizeX.location          = New-Object System.Drawing.Point(10,75)

$lblImageSizeY                   = New-Object system.Windows.Forms.Label
$lblImageSizeY.text              = "Image Scale Y"
$lblImageSizeY.AutoSize          = $true
$lblImageSizeY.width             = 25
$lblImageSizeY.height            = 10
$lblImageSizeY.location          = New-Object System.Drawing.Point(10,100)

$lblImageARI                     = New-Object system.Windows.Forms.Label
$lblImageARI.text                = "Image audio react intensity"
$lblImageARI.AutoSize            = $true
$lblImageARI.width               = 25
$lblImageARI.height              = 10
$lblImageARI.location            = New-Object System.Drawing.Point(10,125)

$numImageAlpha                   = New-Object PSForms.NumericUpDownX
$numImageAlpha.AutoSize          = $true
$numImageAlpha.width             = 25
$numImageAlpha.height            = 10
$numImageAlpha.location          = New-Object System.Drawing.Point(100,50)
$numImageAlpha.Minimum           = 0
$numImageAlpha.Maximum           = 255
$numImageAlpha.Value             = $v["ImageAlpha"]

$numImageSizeX                   = New-Object PSForms.NumericUpDownX
$numImageSizeX.AutoSize          = $true
$numImageSizeX.width             = 25
$numImageSizeX.height            = 10
$numImageSizeX.location          = New-Object System.Drawing.Point(100,75)
$numImageSizeX.DecimalPlaces     = 2
$numImageSizeX.Minimum           = 0
$numImageSizeX.Maximum           = 10
$numImageSizeX.Value             = $v["ImageXScale"]

$numImageSizeY                   = New-Object PSForms.NumericUpDownX
$numImageSizeY.text              = "Image Scale Y"
$numImageSizeY.AutoSize          = $true
$numImageSizeY.width             = 25
$numImageSizeY.height            = 10
$numImageSizeY.location          = New-Object System.Drawing.Point(100,100)
$numImageSizeY.DecimalPlaces     = 2
$numImageSizeY.Minimum           = 0
$numImageSizeY.Maximum           = 10
$numImageSizeY.Value             = $v["ImageYScale"]

$numImageARI                     = New-Object PSForms.NumericUpDownX
$numImageARI.AutoSize            = $true
$numImageARI.width               = 90
$numImageARI.height              = 10
$numImageARI.location            = New-Object System.Drawing.Point(150,125)
$numImageARI.DecimalPlaces       = 1
$numImageARI.Minimum             = 0
$numImageARI.Maximum             = 1
$numImageARI.Value               = $v["ImageAudioReactIntensity"]

$pnlBarColor                     = New-Object System.Windows.Forms.Panel
$pnlBarColor.height              = 25
$pnlBarColor.width               = 100
$pnlBarColor.location            = New-Object System.Drawing.Point(140,40)
$pnlBarColor.BorderStyle         = 2
$pnlBarColor.BackColor           = ToSDColor $v["BarColor"]
$pnlBarColor.Enabled             = $false

$btnApply                        = New-Object system.Windows.Forms.Button
$btnApply.text                   = "Apply"
$btnApply.width                  = 775
$btnApply.height                 = 30
$btnApply.location               = New-Object System.Drawing.Point(10,400)
$btnApply.Font                   = 'Microsoft Sans Serif,10'

$btnLows                         = New-Object system.Windows.Forms.Button
$btnLows.text                    = "Lows"
$btnLows.width                   = 50
$btnLows.height                  = 20
$btnLows.location                = New-Object System.Drawing.Point(70,13)
$btnLows.Font                    = 'Microsoft Sans Serif,8'

$btnMids                         = New-Object system.Windows.Forms.Button
$btnMids.text                    = "Mids"
$btnMids.width                   = 50
$btnMids.height                  = 20
$btnMids.location                = New-Object System.Drawing.Point(130,13)
$btnMids.Font                    = 'Microsoft Sans Serif,8'

$btnAll                          = New-Object system.Windows.Forms.Button
$btnAll.text                     = "All"
$btnAll.width                    = 50
$btnAll.height                   = 20
$btnAll.location                 = New-Object System.Drawing.Point(190,13)
$btnAll.Font                     = 'Microsoft Sans Serif,8'

$colorPicker                     = New-Object System.Windows.Forms.ColorDialog
$colorPicker.AllowFullOpen       = $true
$colorPicker.AnyColor            = $true
$colorPicker.CustomColors        = $true
$colorPicker.FullOpen            = $true
$colorPicker.ShowHelp            = $true

$fileOpenPicker                  = New-Object System.Windows.Forms.OpenFileDialog
$fileOpenPicker.Multiselect      = $false
$fileOpenPicker.AddExtension     = $true
$fileOpenPicker.Filter           = "Image file|*.png;*.jpg"

$btnApply.Add_Click({ applyClick })
$btnLows.Add_Click({ btnLowsClick })
$btnMids.Add_Click({ btnMidsClick })
$btnAll.Add_Click({ btnAllClick })

$btnAddLayer.Add_Click({ btnAddLayerClick })
$btnDeleteLayer.Add_Click({ btnDeleteLayerClick })

$btnSelectImage.Add_Click({ btnSelectImageClick })

$pnlBarColor.Add_Click({ barcolorClick })
$cbMirror.Add_CheckedChanged({ cbMirrorChecked })

function WriteKeyValue([string] $key, [string] $value)
{
    $wpps::WritePrivateProfileString("Variables", $key, $value, $variablesPath)
}

function WriteKeyValueRM([string] $key, [string] $value)
{
    & $rmPath !WriteKeyValue Variables $key $value "$variablesPath"
}

function DeleteKey([string] $key)
{
    $wpps::WritePrivateProfileString("Variables", $key, [NullString]::Value, $variablesPath)
}

function CommandMeasure([string] $measure, [string] $arguments, [string] $config)
{
    & $rmPath !CommandMeasure "$measure" "$arguments" "$config"
}

function tableLayersItemClicked
{
    for ($i = 0; $i -lt $tableLayers.Items.Count; $i++)
    {
        $rectangle = $tableLayers.GetItemRect($i);
        if ($rectangle.Contains([System.Drawing.Point]$_.Location))
        {
            $lvitem = $tableLayers.Items[$i]

            if ($colorPicker.ShowDialog() -eq 1)
            {
                $lvitem.SubItems[1].BackColor = $colorPicker.Color
            }

            return;
        }
    }
}

function cbMirrorChecked 
{
    $cbInvertMirror.Enabled = $cbMirror.Checked
}

function btnLowsClick 
{
    $numFreqMin.Value = 25;
    $numFreqMax.Value = 200;
}

function btnMidsClick 
{
    $numFreqMin.Value = 25;
    $numFreqMax.Value = 2000;
}

function btnAllClick
{
    $numFreqMin.Value = 20;
    $numFreqMax.Value = 15000;
}

function btnDeleteLayerClick
{
    if ($tableLayers.Items.Count -gt 1){
        $tableLayers.Items.RemoveAt($tableLayers.Items.Count-1)
    }
}
function btnAddLayerClick
{
    $layerid = $tableLayers.Items.Count

    if ($layerid -gt 9)
    {
        [System.Windows.Forms.MessageBox]::Show("You have already reached the max number of layers. (10)")
        return
    }

    $lwitem = New-Object System.Windows.Forms.ListViewItem
    $lwitem.UseItemStyleForSubItems=$false
    $lwitem.Name = $layerid
    $lwitem.Text = $layerid
    $lwsubitem = New-Object System.Windows.Forms.ListViewItem+ListViewSubItem
    $lwsubitem.BackColor = [System.Drawing.Color]::White
    $dummy = $lwitem.SubItems.Add($lwsubitem)
    $dummy = $tableLayers.Items.Add($lwitem)
}

function btnSelectImageClick
{
    if ($fileOpenPicker.ShowDialog() -eq 1)
    {
        $imgName = $fileOpenPicker.SafeFileName
        $txtImageName.Text = $imgName
        $fileDestination = "$imagesPath$imgName"
        Copy-Item $fileOpenPicker.FileName -Destination $fileDestination
        $img = [System.Drawing.Image]::Fromfile($fileDestination)
        $pictureBox.Image = $img
    }
}

function applyClick 
{
    $barColor = ToRMColor $pnlBarColor.BackColor
    $doMirror = [int]$cbMirror.Checked
    $doInvertMirror = [int]$cbInvertMirror.Checked
    $doHollowCenter = [int]$cbHollowCenter.Checked
    $fftSize = [Math]::Pow(2, 9 + $cbFFTSize.SelectedIndex)
    $fftBufferSize = [Math]::Pow(2, 12 + $cbFFTBufferSize.SelectedIndex)

    if ($fftBufferSize -lt $fftSize)
    {
        $fftBufferSize = $fftSize
        $cbFFTBufferSize.SelectedIndex = [Math]::Round([Math]::Log($fftSize, 2)-12)
    }

    WriteKeyValue Layers ($tableLayers.Items.Count-1)
    WriteKeyValue DelayPerLayer $numLayers.Value

    # reset layer color values
    foreach ($key in $v.Keys)
    {
        if ($key.StartsWith("Layer") -and $key.EndsWith("Color"))
        {
            DeleteKey $key
        }
    }

    # write layer color values
    foreach ($lwitem in $tableLayers.Items)
    {
        $layerString = "Layer" + $lwitem.Text + "Color"
        $layerColor = ToRMColor $lwitem.SubItems[1].BackColor
        WriteKeyValue $layerString $layerColor
    }

    WriteKeyValue Bands $numBars.Value
    WriteKeyValue Height $numHeight.Value
    #WriteKeyValue BarHeight $numBarHeight.Value
    #WriteKeyValue BarColor $barColor
    WriteKeyValue Radius $numRadius.Value
    WriteKeyValue StartAngle $numStartAngle.Value
    WriteKeyValue EndAngle $numEndAngle.Value
    WriteKeyValue AngularDisplacement $numAngularDisplacement.Value
    WriteKeyValue Smoothing $numSmoothing.Value
    #WriteKeyValue AveragingPastValuesAmount $numPastValueAvg.Value

    WriteKeyValue Mirror $doMirror
    WriteKeyValue InvertMirror $doInvertMirror
    WriteKeyValue HollowCenter $doHollowCenter

    WriteKeyValue FFTSize $fftSize
    WriteKeyValue FFTBufferSize $fftBufferSize
    WriteKeyValue FFTAttack $numFFTAttack.Value
    WriteKeyValue FFTDecay $numFFTDecay.Value
    WriteKeyValue FreqMin $numFreqMin.Value
    WriteKeyValue FreqMax $numFreqMax.Value
    WriteKeyValue Sensitivity $numSensitivity.Value

    WriteKeyValue ImageName $txtImageName.text
    WriteKeyValue ImageXScale $numImageSizeX.Value
    WriteKeyValue ImageYScale $numImageSizeY.Value
    WriteKeyValue ImageAlpha $numImageAlpha.Value
    WriteKeyValue ImageAudioReactIntensity $numImageARI.Value

    CommandMeasure "InitScript" "GenerateTNVis()" $v["Config"]
}

function formClosing 
{
    $pictureBox.Image.Dispose()
}

function barcolorClick 
{
    if ($colorPicker.ShowDialog() -eq 1)
    {
        $pnlBarColor.BackColor = $colorPicker.Color
    }
}


$form.controls.AddRange(@($gbGeneral,$gbBar,$gbSmoothing,$gbVisualization,$gbMirror,$gbFrequency,$gbLayers,$gbImage,$btnApply))
$gbGeneral.controls.AddRange(@($numRadius,$lblRadius, $lblHeight, $numHeight, $lblStartAngle,$lblEndAngle,$lblAngularDisplacement,$numStartAngle,$numEndAngle,$numAngularDisplacement))
$gbBar.controls.AddRange(@($lblBarAmount,$cbHollowCenter,$lblBarWidth,$numBars,$numBarWidth))
$gbSmoothing.controls.AddRange(@($lblSmoothing,$lblPastValueAveraging,$numSmoothing,$numPastValueAvg))
$gbVisualization.controls.AddRange(@($lblFFTSize,$lblFFTBufferSize,$lblFFTAttack,$lblFFTDecay,$lblSensitivity,$numFFTAttack,$numFFTDecay,$cbFFTBufferSize,$cbFFTSize,$numSensitivity))
$gbMirror.controls.AddRange(@($cbMirror,$cbInvertMirror))
$gbFrequency.controls.AddRange(@($lblStartFreqency,$lblEndFreqency,$lblPresets,$numFreqMin,$numFreqMax,$btnLows,$btnMids,$btnAll))
$gbLayers.Controls.AddRange(@($lblLayers, $numLayers, $tableLayers, $btnAddLayer,$btnDeleteLayer))
$gbImage.Controls.AddRange(@($txtImageName, $pictureBox,$btnSelectImage,$lblImageAlpha,$lblImageSizeX,$lblImageSizeY,$lblImageARI,$numImageAlpha,$numImageSizeX,$numImageSizeY,$numImageARI))

$form.ResumeLayout()

[Windows.Forms.Application]::Run($form)