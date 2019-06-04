$o = new-object -COM Shell.Application
$contains = $false
$vvvvFolder = ''
$installFolder = $pwd.path

while (!$contains) {
  $fileDialog = $o.BrowseForFolder(0,'Please choose the VVVV install folder.',0,0)
  if ([string]::IsNullOrEmpty($fileDialog)) {
    write 'Cancelled'
    exit 1
  }

  $vvvvFolder = $fileDialog.self.path
  $contains = Test-Path ($vvvvFolder+"\vvvv.exe")
}

cd $vvvvFolder
cd lib
cd packs

./nuget.exe install Csv -version 1.0.38
./nuget.exe install ncalc -version 1.3.8
./nuget.exe install VL.IO.Xbox360Controller -version 1.0.0
./nuget.exe install VL.Skia -prerelease -version 0.94.30-g7af1280a81

write 'Finished installing dependencies'

copy ($installFolder+'\splash.bmp') ($vvvvFolder+'\lib\splash.bmp')

write 'Added stamp of approval (splash.bmp)'
