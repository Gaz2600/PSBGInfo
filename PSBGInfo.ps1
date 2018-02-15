#=========================================================================== 
# Created By jai47 ©2017 
# Modified By gaz2600 @2018
# https://gallery.technet.microsoft.com/scriptcenter/Windows-PowerShell-System-792a1db9
#=========================================================================== 
Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 
[xml]$XAML = @' 
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" 
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008" 
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
        xmlns:local="clr-namespace:WpfApp3" 
        Name="window" WindowStyle="None" Height="150" Width="420" Opacity="0.85" AllowsTransparency="True"> 
        <Window.Resources> 
        <Style TargetType="GridViewColumnHeader"> 
            <Setter Property="Background" Value="Transparent" /> 
            <Setter Property="Foreground" Value="Transparent"/> 
            <Setter Property="BorderBrush" Value="Transparent"/> 
            <Setter Property="FontWeight" Value="Bold"/> 
            <Setter Property="Opacity" Value="0.5"/> 
            <Setter Property="Template"> 
                <Setter.Value> 
                    <ControlTemplate TargetType="GridViewColumnHeader"> 
                    <Border Background="Transparent"> 
                    <ContentPresenter></ContentPresenter> 
                    </Border> 
                    </ControlTemplate> 
                </Setter.Value> 
            </Setter> 
        </Style> 
        </Window.Resources> 
    <Grid Name="grid" Height="150" HorizontalAlignment="Left" VerticalAlignment="Top"> 
        <Label Name="Title" Content="Technology Support Information" HorizontalAlignment="Left" VerticalAlignment="Top" Width="420" Height="40" Background="#313130" Foreground="#6996e3" FontWeight="Bold" FontSize="17"/> 
        
        <Label Content="Hostname" HorizontalAlignment="Left" Margin="0,37,0,0" VerticalAlignment="Top" Width="125" Height="30" Background="#313130" Foreground="White" FontSize="14"/> 
        <TextBox Name="txtHostName" Height="20" Margin="130,43,5,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" IsEnabled="True" AllowDrop="True" BorderThickness="0" HorizontalAlignment="Left" Width="290" FontSize="14"/> 

        <Label Content="IP Address" HorizontalAlignment="Left" Margin="0,64.5,0,0" VerticalAlignment="Top" Width="125" Height="30" Background="#313130" Foreground="White" FontSize="14"/> 
        <TextBox Name="txtWindowsIP" HorizontalAlignment="Left" Height="20" Margin="130,70,5,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="290" IsEnabled="True" BorderThickness="0" FontSize="14"/> 
        
        <Label Content="Operating System" HorizontalAlignment="Left" Margin="0,92,0,0" VerticalAlignment="Top" Width="125" Height="30" Background="#313130" Foreground="White" FontSize="14"/> 
        <TextBox Name="txtOSName" HorizontalAlignment="Left" Height="20" Margin="130,97.5,5,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="290" IsEnabled="True" BorderThickness="0" FontSize="14"/> 
        
        <Label Content="Image Version" HorizontalAlignment="Left" Margin="0,119.5,0,0" VerticalAlignment="Top" Width="125" Height="30" Background="#313130" Foreground="White" FontSize="14"/> 
        <TextBox Name="txtImageVersion" HorizontalAlignment="Left" Height="20" Margin="130,125,5,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="290" IsEnabled="True" BorderThickness="0" FontSize="14"/> 
        
        
            <ListView Name="listview" SelectionMode="Single" Foreground="White" Background="Transparent" BorderBrush="Transparent" IsHitTestVisible="False"> 
                <ListView.ItemContainerStyle> 
                    <Style> 
                        <Setter Property="Control.HorizontalContentAlignment" Value="Stretch"/> 
                        <Setter Property="Control.VerticalContentAlignment" Value="Stretch"/> 
                    </Style> 
                </ListView.ItemContainerStyle> 
            </ListView> 
    </Grid> 
</Window> 
'@ 
 
#Read XAML 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)  
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )} 
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit} 
 
#=========================================================================== 
# Store Form Objects In PowerShell 
#=========================================================================== 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)} 
 
Function RefreshData{ 
#=========================================================================== 
# Stores WMI values in WMI Object from System Classes 
#=========================================================================== 
$oWMIOS = @() 
$oWMINIC = @() 
$oWMIOS = Get-WmiObject win32_OperatingSystem 
$oWMINIC = Get-WmiObject Win32_NetworkAdapterConfiguration | Where { $_.IPAddress } | Select -Expand IPAddress | Where { $_ -like '1*' } 
$imgVersion = Get-Content "C:\ImageVersion.txt"
$Win10Ver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId
#=========================================================================== 
# Links WMI Object Values to XAML Form Fields 
#=========================================================================== 
$txtHostName.Text = $oWMIOS.PSComputerName 
 
#Formats and displays OS name 
$aOSName = $oWMIOS.name.Split("|") 
$txtOSName.Text = ($aOSName[0] + " " + "(" + $Win10Ver + ")")
 

#Displays IP Address 
$txtWindowsIP.Text = $oWMINIC 
 
 
#Displays OS Version details 
$txtImageVersion.Text = ($imgVersion + " (" + $oWMIOS.version +")")
}
 
#=========================================================================== 
# Build Tray Icon 
#=========================================================================== 
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\HelpPane.exe") 
 
# Populate ListView with PS Object data and set width  
$listview.ItemsSource = $disks 
$listview.Width = $grid.width*.9  
 
# Create GridView object to add to ListView  
$gridview = New-Object System.Windows.Controls.GridView  
  
# Dynamically add columns to GridView, then bind data to columns  
foreach ($column in $columnorder) {  
    $gridcolumn = New-Object System.Windows.Controls.GridViewColumn  
    $gridcolumn.Header = $column  
    $gridcolumn.Width = $grid.width*.20  
    $gridbinding = New-Object System.Windows.Data.Binding $column  
    $gridcolumn.DisplayMemberBinding = $gridbinding  
    $gridview.AddChild($gridcolumn)  
}  
  
# Add GridView to ListView  
$listview.View = $gridview  
  
# Create notifyicon, and right-click -> Exit menu  
$notifyicon = New-Object System.Windows.Forms.NotifyIcon  
$notifyicon.Text = "System Resources"  
$notifyicon.Icon = $icon  
$notifyicon.Visible = $true  
  
$menuitem = New-Object System.Windows.Forms.MenuItem  
$menuitem.Text = "Exit"  
 
$contextmenu = New-Object System.Windows.Forms.ContextMenu  
$notifyicon.ContextMenu = $contextmenu  
$notifyicon.contextMenu.MenuItems.AddRange($menuitem)  
  
# Add a left click that makes the Window appear in the lower right part of the screen, above the notify icon.  
$notifyicon.add_Click({  
    if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {  
            # reposition each time, in case the resolution or monitor changes  
        $window.Left = $([System.Windows.SystemParameters]::WorkArea.Width-$window.Width)  
            $window.Top = $([System.Windows.SystemParameters]::WorkArea.Height-$window.Height)  
            $window.Show()  
            $window.Activate() 
            RefreshData 
    }  
})  
  
# Close the window if it's double clicked  
$window.Add_MouseDoubleClick({  
    RefreshData 
})  
  
#Close the window if it loses focus  
$window.Add_Deactivated({  
    $window.Hide() 
})  
  
# When Exit is clicked, close everything and kill the PowerShell process  
$menuitem.add_Click({  
   $notifyicon.Visible = $false  
   $window.close()  
   Stop-Process $pid  
})  
  
# Make PowerShell Disappear  
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'  
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru 
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)  
  
Force garbage collection just to start slightly lower RAM usage.  
[System.GC]::Collect()  
  
Create an application context for it to all run within.  
This helps with responsiveness, especially when clicking Exit.  
$appContext = New-Object System.Windows.Forms.ApplicationContext  
[void][System.Windows.Forms.Application]::Run($appContext)
