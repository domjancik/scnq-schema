cd Fonts

$folderPath = $pwd.Path

$o = new-object -com Shell.Application
$folder = $o.NameSpace($folderPath)

$files = Get-ChildItem -Path $folderPath
ForEach($f in $files){
  $folder.ParseName($f.Name).Verbs() | %{ if($_.Name -eq '&Install'){ $_.DoIt() } }
}

write 'Fonts installed'