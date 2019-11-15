unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, FileUtil, FileCtrl, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Spin, ExtCtrls, IdStack, IdSocketHandle, IdHTTPServer,
  LCLType, AsyncProcess, Windows, IdCustomHTTPServer, IdContext, IdGlobal,
  IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    AsyncProcess1: TAsyncProcess;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    IdHTTPServer1: TIdHTTPServer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Label4Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure Memo1EditingDone(Sender: TObject);
    procedure Memo1Enter(Sender: TObject);
    procedure Memo1Exit(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Memo1KeyPress(Sender: TObject; var Key: char);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Memo1MouseEnter(Sender: TObject);
    procedure Memo1MouseLeave(Sender: TObject);
    procedure Memo1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Memo1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Memo1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
  private
    { private declarations }
  public
    { public declarations }
  end;

  procedure Print(pText: String);
  procedure WriteINI;
  procedure ReadINI;
  function FileSizeToStr(const ASize: Int64): String;
  function ListFiles(Directory: String): TStringList;
  function GetLastFolder(URL: String): String;

var
  Form1: TForm1;
  ApplicationVersionStr: String;
  RcmdBuffer: String;
  Binding: TIdSocketHandle;

const
  STR_Copyright:      String = '© 2019 Alexander Feuster (alexander.feuster@gmail.com)'+#13#10+'http://github.com/feuster/MiniHTTP/';
  STR_Copyright_HTML: String = '&copy; 2013-2019 Alexander Feuster';
  STR_CPU:            String = {$I %FPCTARGETCPU%};
  STR_Server_starten: String = 'Server starten';
  STR_Server_stoppen: String = 'Server stoppen';
  BASE64_Folder_Icon: String = '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAN1wAADdcBQiibeAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAHCSURBVDiNpZAxa5NRFIafc+9XLCni4BC6FBycMnbrLpkcgtDVX6C70D/g4lZX/4coxLlgxFkpiiSSUGm/JiXfveee45AmNlhawXc53HvPee55X+l2u/yPqt3d3Tfu/viatwt3fzIYDI5uBJhZr9fr3TMzzAx3B+D09PR+v98/7HQ6z5fNOWdCCGU4HH6s67oAVDlnV1UmkwmllBUkhMD29nYHeLuEAkyn06qU8qqu64MrgIyqYmZrkHa73drc3KTVahFjJITAaDRiPB4/XFlQVVMtHH5IzJo/P4EA4MyB+erWPQB7++zs7ccYvlU5Z08pMW2cl88eIXLZeDUpXzsBkNQ5eP1+p0opmaoCTgzw6fjs6gLLsp58FB60t0DcK1Ul54yIEIMQ43Uj68pquDmCeJVztpwzuBNE2LgBoMVpslHMCUEAFgDVxQbzVAiA+aK5uGPmmDtZF3VpoUm2ArhqQaRiUjcMf81p1G60UEVhcjZfAFTVUkrgkS+jc06mDX9nvq4YhJ9nlxZExMwMEaHJRutOdWuIIsJFUoBSuTvHJ4YIfP46unV4qdlsjsBRZRtb/XfHd5+C8+P7+J8BIoxFwovfRxYhnhxjpzEAAAAASUVORK5CYII=" border="0"/>';
  BASE64_File_Icon:   String = '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAB3RJTUUH3QwKCwIFhjDR2AAAAAlwSFlzAAALEwAACxMBAJqcGAAAAARnQU1BAACxjwv8YQUAAADXSURBVHjanVNLCsIwEJ18cCfB0JXQldfyBj1Fe4e67EZP4zW6bUHpSomtTegvaRJTH0xmCHlv5g0EFUVxLcvyDBuQJAmSOYoigDRNu1+oqmoK+V5xmj10DQY6qtZ1DW3bqhohNHVb1kN3yPMc3uIAOypmAZNsEk0gRaWAtctA8qCggH1kn5AQkvrRJ7BN48LjyfvzNe/ANoXMMsb9LHE83VWmPvKYCSFTzRjThJwWQi2tLLhsuIB9Hcw72xurhRCxlQXOeeg6dIE4jm9Zlm36jT3n8lc3G74KsVsSykNQZQAAAABJRU5ErkJggg==" border="0"/>';
  BASE64_HTTP_Icon:   String = '<img src="data:image/png;base64,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" border="0"/>';

implementation

{$R *.lfm}

{ TForm1 }

procedure Print(pText: String);
//Text schreiben
begin
  Form1.Memo1.Lines.Add(pText);
end;

function FileSizeToStr(const ASize: Int64): String;
//Int64 Dateigröße nach String umwandeln und formatieren
const
  Units: array[0..8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  Index: Integer;

begin
  Assert(ASize >= 0);
  Index:=Trunc(ln(ASize)/ln(2)/10);
  Result:=Format('%.0f %s', [ASize/(1 shl (Index*10)), Units[Index]]);
end;

function GetLastFolder(URL: String): String;
//letzen Ordner aus URL Adresse extrahieren
begin
  URL:=StringReplace(URL,'\','/',[rfReplaceAll, rfIgnoreCase]);
  if RightStr(URL,1)='/' then
    URL:=LeftStr(URL, Length(URL)-1);
  URL:=RightStr(URL,Length(URL)-LastDelimiter('/',URL));
  URL:=URL+'/';
  result:=URL;
end;

function ListFiles(Directory: String): TStringList;
//Dateien auflisten
var
  SearchRec: TSearchRec;
  List: TStringList;
  LocalFolder: String;

begin
  try
  List:=TStringList.Create;

  //Startpfad aufbereiten
  LocalFolder:=RightStr(Directory,Length(Directory)-Length(Form1.Edit1.Text));
  LocalFolder:=StringReplace(LocalFolder,'\','/',[rfReplaceAll, rfIgnoreCase]);
  Directory:=StringReplace(Directory,'/','\',[rfReplaceAll, rfIgnoreCase]);
  if (RightStr(Directory,1)<>'\') then
    Directory:=Directory+'\';
  if DirectoryExists(Directory)=false then
    begin
        result:=List;
        exit;
    end;

  //Ordner suchen
  if FindFirst(Directory+'*', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        if SearchRec.Attr=faDirectory then
          List.Add(LocalFolder+SearchRec.Name+'/');
      until FindNext(SearchRec) <> 0;
    end;
  FindClose(SearchRec.FindHandle);

  //Dateien suchen
  if FindFirst(Directory+'*', faAnyFile, SearchRec) = 0 then
    begin
      repeat
        if SearchRec.Attr<>faDirectory then
          List.Add(LocalFolder+SearchRec.Name);
      until FindNext(SearchRec) <> 0;
    end;
  FindClose(SearchRec.FindHandle);

  //Ergebnis
  result:=List;
  except
    on E:Exception do
    begin
      Print('Fehler: "'+E.Message+'" ist in ListFiles("'+Directory+'") aufgetreten!');
      result:=List;
    end;
  end;
end;

function ApplicationVersion: String;
//Dateiversion aus EXE auslesen
var
  aFileName: array [0..MAX_PATH] of Char;
  pdwHandle: DWORD;
  nInfoSize: DWORD;
  pFileInfo: Pointer;
  pFixFInfo: PVSFixedFileInfo;
  nFixFInfo: DWORD;

begin
  //Gibt Versionsnummer zurück
  if ApplicationVersionStr<>'' then
    begin
      result:=ApplicationVersionStr;
      exit;
    end;
  StrPCopy(aFileName,Application.ExeName);
  pdwHandle := 0;
  nInfoSize := GetFileVersionInfoSize(aFileName, pdwHandle);
  result:='0';
  if nInfoSize <> 0 then
    pFileInfo := GetMemory(nInfoSize)
  else
    pFileInfo := nil;
  if Assigned(pFileInfo) then
  begin
    try
      if GetFileVersionInfo(aFileName, pdwHandle, nInfoSize, pFileInfo) then
      begin
        pFixFInfo := nil;
        nFixFInfo := 0;
        if VerQueryValue(pFileInfo, '\', Pointer(pFixFInfo), nFixFInfo) then
        begin
          {
          result := Format('%d.%d.%d.%d',[HiWord(pFixFInfo^.dwFileVersionMS),
          LoWord(pFixFInfo^.dwFileVersionMS),HiWord(pFixFInfo^.dwFileVersionLS),
          LoWord(pFixFInfo^.dwFileVersionLS)]);
          }
          result := Format('%d.%d',[HiWord(pFixFInfo^.dwFileVersionMS),LoWord(pFixFInfo^.dwFileVersionLS)]);

        end;
      end;
    finally
      FreeMemory(pFileInfo);
    end;
  end;
end;

procedure WriteINI;
//Einstellungen speichern
var
  INI: TIniFile;

begin
  INI:=TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  INI.WriteString('Application','Version',ApplicationVersion);
  INI.WriteString('Settings','IP',Form1.ComboBox1.Text);
  INI.WriteInteger('Settings','Port',Form1.SpinEdit1.Value);
  INI.WriteString('Settings','FilePath',Form1.Edit1.Text);
  INI.WriteBool('Settings','ListContent',Form1.CheckBox1.Checked);
  if INI<>NIL then
    INI.Free;
end;

procedure ReadINI;
//Einstellungen laden
var
  INI: TIniFile;

begin
  INI:=TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  Form1.ComboBox1.ItemIndex:=Form1.ComboBox1.Items.IndexOf(INI.ReadString('Settings','IP','127.0.0.1'));
  Form1.SpinEdit1.Value:=INI.ReadInteger('Settings','Port',80);
  Form1.Edit1.Text:=INI.ReadString('Settings','FilePath',Form1.Edit1.Text);
  Form1.CheckBox1.Checked:=INI.ReadBool('Settings','ListContent',true);
  if INI<>NIL then
    INI.Free;
end;

function StartServer: Boolean;
//Server starten
begin
  try
  Print('');
  with Form1 do
    begin
      if IdHTTPServer1.Active=true then
        begin
          Print('Server bereits aktiv!');
          result:=true;
          exit;
        end;
      IdHTTPServer1.Bindings.Clear;
      Binding:=IdHTTPServer1.Bindings.Add;
      Binding.IP:=ComboBox1.Text;
      Binding.Port:=StrToIntDef(SpinEdit1.Text,80);
      Binding.ReuseSocket:=rsTrue;
      IdHTTPServer1.KeepAlive:=true;
      IdHTTPServer1.DefaultPort:=Binding.Port;
      IdHTTPServer1.Bindings.DefaultPort:=Binding.Port;
      IdHTTPServer1.AutoStartSession:=true;
      IdHTTPServer1.MaxConnections:=100;
      IdHTTPServer1.Active:=true;
    end;
  finally
  if Form1.IdHTTPServer1.Active=true then
    begin
      Print('Server mit IP '+Binding.IP+':'+IntToStr(Binding.Port)+' gestartet');
      if FileExists(ExtractFilePath(Application.ExeName)+'help.rcmd')=true then
        Print('Eine Kurzhilfe kann im Browser über die URL "http://'+Binding.IP+':'+IntToStr(Binding.Port)+'/help.rcmd" aufgerufen werden');
    end
  else
    Print('Server nicht gestartet!');
  result:=Form1.IdHTTPServer1.Active;
  end;
end;

function StopServer: Boolean;
//Server stoppen
begin
  try
  if Form1.IdHTTPServer1.Active=false then
    begin
      result:=true;
      exit;
    end;
  Print('');
  Form1.IdHTTPServer1.Active:=false;
  finally
  if Form1.IdHTTPServer1.Active=true then
    Print('Server konnte nicht gestoppt werden!')
  else
    Print('Server gestoppt');
  result:=not Form1.IdHTTPServer1.Active;
  end;
end;

procedure CorrectFilesFolderPath;
//Dateipfad ggfs. korrigieren
begin
  with Form1 do
    begin
      Edit1.Text:=StringReplace(Edit1.Text,'/','\',[rfReplaceAll, rfIgnoreCase]);
      if RightStr(Edit1.Text,1)<>'\' then
        Edit1.Text:=Edit1.Text+'\';
      if (Edit1.Text='') or (Edit1.Text='\') or (DirectoryExists(Edit1.Text)=false) then
        begin
          Edit1.Text:=ExtractFilePath(Application.ExeName);
        end;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
//Programm starten
begin
  try
  Form1.Caption:=Application.Title+' V'+ApplicationVersion;
  Form1.Constraints.MinHeight:=Form1.Height;
  Form1.Constraints.MinWidth:=Form1.Width;
  Button1.Caption:=STR_Server_starten;

  //lokale IP Adressen auflisten und LocalHost hinzufügen
  try
  gStack.AddLocalAddressesToList(ComboBox1.Items);
  finally
  ComboBox1.Items.Add('127.0.0.1');
  end;
  ComboBox1.ItemIndex:=0;


  //Einstellungen lesen
  ReadINI;
  if ComboBox1.ItemIndex=-1 then
    ComboBox1.ItemIndex:=0;

  //Dateipfad ggfs. korrigieren
  CorrectFilesFolderPath;

  //Copyright- und Versionsinfo anzeigen
  if LowerCase(STR_CPU)='x86_64' then
    Print(Form1.Caption+' (64Bit) '+STR_Copyright)
  else if LowerCase(STR_CPU)='i386' then
    Print(Form1.Caption+' (32Bit) '+STR_Copyright)
  else
    Print(Form1.Caption+' ('+STR_CPU+') '+STR_Copyright);

  except
    on E:Exception do
    begin
      Print('Fehler: "'+E.Message+'" ist in FormCreate() aufgetreten!');
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
//Server starten/stoppen
begin
  try
  if IdHTTPServer1.Active=false then
    begin
      if StartServer=true then
        begin
          Button1.Caption:=STR_Server_stoppen;
          Button2.Enabled:=false;
          ComboBox1.Enabled:=false;
          SpinEdit1.Enabled:=false;
          Edit1.Enabled:=false;
        end;
    end
  else
    begin
      if StopServer=true then
        begin
          Button1.Caption:=STR_Server_starten;
          Button2.Enabled:=true;
          ComboBox1.Enabled:=true;
          SpinEdit1.Enabled:=true;
          Edit1.Enabled:=true;
        end;
    end;
  except
    on E:Exception do
    begin
      Print('Fehler: "'+E.Message+'" ist in Button1Click() aufgetreten!');
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
//Ordner für Server Dateien einstellen
begin
  if DirectoryExists(Edit1.Text)=true then
    SelectDirectoryDialog1.InitialDir:=Edit1.Text
  else
    SelectDirectoryDialog1.InitialDir:=ExtractFilePath(Application.ExeName);
  if SelectDirectoryDialog1.Execute=true then
    begin
      Edit1.Text:=SelectDirectoryDialog1.FileName;
      //Dateipfad ggfs. korrigieren
      CorrectFilesFolderPath;
    end;
end;

procedure TForm1.Edit1Change(Sender: TObject);
//Pfadanzeige anpassen
begin
  Panel2.Caption:=MinimizeName(Edit1.Text,Panel2.Canvas,Panel2.ClientWidth);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
//Programm beenden
begin
  try
  StopServer;
  WriteINI;
  finally
  canClose:=true;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
//Automatische Größenanpassung
begin
  Panel1.Left:=0;
  Panel1.Top:=Form1.ClientHeight-Panel1.Height;
  Panel1.Width:=Form1.ClientWidth;
  Memo1.Left:=0;
  Memo1.Top:=0;
  Memo1.Width:=Form1.ClientWidth;
  Memo1.Height:=Form1.ClientHeight-Panel1.Height;
  Edit1.Width:=Form1.ClientWidth-Edit1.Left-Button2.Left;
  Panel2.Top:=Button2.Top;
  Panel2.Left:=ComboBox1.Left;
  Panel2.Width:=Form1.ClientWidth-Panel2.Left-Button2.Left;
  Panel2.Height:=Button2.Height;
  Panel2.Caption:=MinimizeName(Edit1.Text,Panel2.Canvas,Panel2.ClientWidth);
end;

procedure TForm1.IdHTTPServer1CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
//HTTP Anfrage auswerten und Datei senden oder Ordner öffnen
var
  GetFile: String;
  LocalFile: String;
  TempFile: String;
  Buffer: String;
  ByteSent: Cardinal;
  Stream: TMemoryStream;
  FileList: TStringList;
  Counter: Integer;
  TimeStart: DWord;
  TimeEnd: DWord;
  RedirectHTML: Boolean;

begin
  try
  Print('');
  GetFile:=RightStr(ARequestInfo.Document, Length(ARequestInfo.Document)-1);
  GetFile:=StringReplace(GetFile,'/','\',[rfReplaceAll, rfIgnoreCase]);

  //Remote Befehle ausführen
  if (AnsiRightStr(LowerCase(GetFile),5)='.rcmd') then
    begin
      Print('Remote Befehl "'+StringReplace(GetFile,'\','/',[rfReplaceAll, rfIgnoreCase])+'" angefordert von IP '+ARequestInfo.RemoteIP);
      Print('User Agent: '+ARequestInfo.UserAgent);
      AResponseInfo.RawHeaders.Clear;
      AResponseInfo.RawHeaders.Add('Cache-Control: no-store, no-cache, must-revalidate');
      AResponseInfo.RawHeaders.Add('Cache-Control: post-check=0, pre-check=0');
      AResponseInfo.RawHeaders.Add('Pragma: no-cache');
      AResponseInfo.Clear;
      AResponseInfo.ContentType:='text/html';
      if (FileExists(ExtractFilePath(Application.ExeName)+GetFile)) or (FileExists(Edit1.Text+GetFile)) then
        begin
          //200 Header für vorhandenen Remote Befehl
          AResponseInfo.ContentText:='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/transitional.dtd"><html><title>Remote Command Status Status</title>';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'<style type="text/css">body { background-color:#FFFFFF; font-family:monospace,verdana,arial; } a:link { text-decoration:none; font-weight:normal; color:#0000FF;} a:visited { text-decoration:none; font-weight:normal; color:#0080FF;} a:hover { text-decoration:underline; font-weight:bold; color:#004080; } a:active { text-decoration:none; font-weight:normal; color:#0000FF; } a:focus { text-decoration:none; font-weight:normal; color:#0000FF; }</style><body>';
          AResponseInfo.ResponseNo:=200;
          AResponseInfo.ResponseText:='200 OK';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'<font color="black" size=+3><table border="0"><tr><td>'+BASE64_HTTP_Icon+'</td><td><b>&nbsp;Remote Command Status</b></td></tr></table><font size=+1><br>';
          if FileExists(ExtractFilePath(Application.ExeName)+GetFile) then
            begin
             LocalFile:=ExtractFilePath(Application.ExeName)+GetFile;
             AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command file "'+GetFile+'" found in application folder<br><br>';
            end;
          if LocalFile='' then
            begin
              if (FileExists(Edit1.Text+GetFile)) then
                begin
                 LocalFile:=Edit1.Text+GetFile;
                 AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command file "'+GetFile+'" found in application folder<br><br>';
                end;
            end;
          if FileExists(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat'))) then
            DeleteFile(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')));
          if CopyFile(PChar(LocalFile), PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')), true) then
            begin
              Stream:=TMemoryStream.Create;
              Stream.LoadFromFile(LocalFile);
              if Stream.Size>0 then
                begin
                  FileList:=TStringList.Create;
                  FileList.Clear;
                  FileList.LoadFromFile(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')));
                  //Remote Befehlsausgabe als HTML Seite Option auswerten
                  if UpperCase(FileList.Strings[0])='::HTMLOUTPUT::' then
                    begin
                      RedirectHTML:=true;
                      AsyncProcess1.CommandLine:=PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')+' > '+ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')+'.txt 2>&1');
                    end
                  else
                    begin
                      RedirectHTML:=false;
                      AsyncProcess1.CommandLine:=PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat'));
                    end;
                  FileList.Free;
                  AsyncProcess1.ConsoleTitle:=Application.Title+' Server V'+ApplicationVersion;
                  TimeStart:=GetTickCount;
                  AsyncProcess1.Execute;
                  while AsyncProcess1.Running do
                    begin
                      Application.ProcessMessages;
                    end;
                  if RedirectHTML=false then
                    begin
                      TimeEnd:=GetTickCount-TimeStart;
                      AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command execution took '+IntToStr(TimeEnd)+' ms<br><br>';
                      AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command exit code '+IntToStr(AsyncProcess1.ExitCode)+' and exit status '+IntToStr(AsyncProcess1.ExitStatus)+'<br><br>';
                      AResponseInfo.ContentText:=AResponseInfo.ContentText+'<br><br><br><font size=-1>Info page generated at '+TimeToStr(Time)+'<br>by <a href="http://github.com/feuster/MiniHTTP/">'+Application.Title+' V'+ApplicationVersion+'</a> '+STR_Copyright_HTML+'<br><br></body></html>';
                    end
                  else
                    begin
                      AResponseInfo.ContentText:='';
                      FileList:=TStringList.Create;
                      FileList.Clear;
                      FileList.LoadFromFile(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')+'.txt'));
                      for Counter:=0 to FileList.Count-1 do
                        begin
                          AResponseInfo.ContentText:=AResponseInfo.ContentText+FileList.Strings[Counter];
                        end;
                      FileList.Free;
                    end;
                  Print('Remote Befehl Ausführung benötigte '+IntToStr(TimeEnd)+' ms');
                  Print('Remote Befehl exit code '+IntToStr(AsyncProcess1.ExitCode)+' und exit status '+IntToStr(AsyncProcess1.ExitStatus));
                end
              else
                begin
                  AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command not executed due to empty "'+GetFile+'" file<br><br>';
                  AResponseInfo.ContentText:=AResponseInfo.ContentText+'<br><br><br><font size=-1>Info page generated at '+TimeToStr(Time)+'<br>by <a href="http://github.com/feuster/MiniHTTP/">'+Application.Title+' V'+ApplicationVersion+'</a> '+STR_Copyright_HTML+'<br><br></body></html>';
                  Print('Remote Befehlsdatei enthält keine Befehle (0 Byte Größe)');
                end;
              Stream.Free;
            end;
          AResponseInfo.ServerSoftware:=Application.Title+' Server V'+ApplicationVersion;
          //Tempdateien aufräumen
          if FileExists(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat'))) then
            DeleteFile(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')));
          if FileExists(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')+'.txt')) then
            DeleteFile(PChar(ChangeFileExt(GetTempDir+ExtractFilename(LocalFile),'.bat')+'.txt'));
        end
      else
        begin
          //404 Header für nicht vorhandenen Remote Befehl
          AResponseInfo.ContentText:='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/transitional.dtd"><html><title>Remote Command Error</title>';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'<style type="text/css">body { background-color:#FFFFFF; font-family:monospace,verdana,arial; } a:link { text-decoration:none; font-weight:normal; color:#0000FF;} a:visited { text-decoration:none; font-weight:normal; color:#0080FF;} a:hover { text-decoration:underline; font-weight:bold; color:#004080; } a:active { text-decoration:none; font-weight:normal; color:#0000FF; } a:focus { text-decoration:none; font-weight:normal; color:#0000FF; }</style><body>';
          AResponseInfo.ResponseNo:=404;
          AResponseInfo.ResponseText:='404 Not found';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'<font color="black" size=+3><table border="0"><tr><td>'+BASE64_HTTP_Icon+'</td><td><b>&nbsp;Remote Command Error</b></td></tr></table><font size=+1><br>';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'Remote command file "'+GetFile+'" not found in application folder or server content folder<br><br>';
          AResponseInfo.ContentText:=AResponseInfo.ContentText+'<br><br><br><font size=-1>Error page generated at '+TimeToStr(Time)+'<br>by <a href="http://github.com/feuster/MiniHTTP/">'+Application.Title+' V'+ApplicationVersion+'</a> '+STR_Copyright_HTML+'<br><br></body></html>';
          AResponseInfo.ServerSoftware:=Application.Title+' Server V'+ApplicationVersion;
          Print('Remote Datei "'+GetFile+'" weder im Applikationsordner noch im Serverordner gefunden');
        end;
      AResponseInfo.Server:=ComboBox1.Text;
      AResponseInfo.WriteHeader;
      AResponseInfo.WriteContent;
      exit;
    end;

  if (Length(GetFile)<>0) and (RightStr(GetFile,1)<>'\') then
    begin
      Print('Datei "'+StringReplace(GetFile,'\','/',[rfReplaceAll, rfIgnoreCase])+'" angefordert von IP '+ARequestInfo.RemoteIP);
      Print('User Agent: '+ARequestInfo.UserAgent);
      LocalFile:=Edit1.Text+GetFile;
    end
  else
    begin
      if FileExists(Edit1.Text+'index.html') then
        LocalFile:=Edit1.Text+'index.html'
      else if FileExists(Edit1.Text+'index.htm') then
        LocalFile:=Edit1.Text+'index.htm'
      else if FileExists(Edit1.Text+GetFile+'index.html') then
        LocalFile:=Edit1.Text+GetFile+'index.html'
      else if FileExists(Edit1.Text+GetFile+'index.htm') then
        LocalFile:=Edit1.Text+GetFile+'index.htm'
      else
        LocalFile:='';
    end;

  if FileExists(LocalFile) then
    begin
      AResponseInfo.RawHeaders.Clear;
      AResponseInfo.RawHeaders.Add('Cache-Control: no-store, no-cache, must-revalidate');
      AResponseInfo.RawHeaders.Add('Cache-Control: post-check=0, pre-check=0');
      AResponseInfo.RawHeaders.Add('Pragma: no-cache');
      AResponseInfo.ResponseNo:=200;
      AResponseInfo.ResponseText:='200 OK';
      AResponseInfo.ServerSoftware:=Application.Title+' Server V'+ApplicationVersion;
      AResponseInfo.Server:=ComboBox1.Text;
      AResponseInfo.ContentType:=IdHTTPServer1.MIMETable.GetFileMIMEType(LocalFile);
      AResponseInfo.ContentDisposition:='inline';
      Print('"'+LocalFile+'" ('+AResponseInfo.ContentType+') wird gesendet');
      Stream:=TMemoryStream.Create;
      Stream.LoadFromFile(LocalFile);
      AResponseInfo.ContentLength:=Stream.Size;
      ByteSent:=AResponseInfo.ServeFile(AContext, LocalFile);
      Stream.Free;
      Print(IntToStr(ByteSent)+' Bytes gesendet');
    end
  else
    begin
      if (Length(GetFile)<>0) then
        begin
          if (RightStr(GetFile,1)<>'\') then
            Print('Datei "'+StringReplace(Edit1.Text+GetFile,'/','\',[rfReplaceAll, rfIgnoreCase])+'" ist nicht vorhanden')
          else
            begin
              if DirectoryExists(StringReplace(Edit1.Text+GetFile,'/','\',[rfReplaceAll, rfIgnoreCase]))=true then
                Print('Öffne Ordner "'+StringReplace(Edit1.Text+GetFile,'/','\',[rfReplaceAll, rfIgnoreCase])+'"')
              else
                Print('Ordner "'+StringReplace(Edit1.Text+GetFile,'/','\',[rfReplaceAll, rfIgnoreCase])+'" nicht vorhanden');
            end
        end
      else
        begin
          if LocalFile='' then
            Print('Index Datei ist nicht vorhanden');
        end;

      //404 Header
      AResponseInfo.Clear;
      AResponseInfo.ContentType:='text/html';
      AResponseInfo.ContentText:='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/transitional.dtd"><html><title>Error 404</title>';
      AResponseInfo.ContentText:=AResponseInfo.ContentText+'<style type="text/css">body { background-color:#FFFFFF; font-family:monospace,verdana,arial; } a:link { text-decoration:none; font-weight:normal; color:#0000FF;} a:visited { text-decoration:none; font-weight:normal; color:#0080FF;} a:hover { text-decoration:underline; font-weight:bold; color:#004080; } a:active { text-decoration:none; font-weight:normal; color:#0000FF; } a:focus { text-decoration:none; font-weight:normal; color:#0000FF; }</style><body>';
      AResponseInfo.ContentText:=AResponseInfo.ContentText+'<font color="black" size=+3><table border="0"><tr><td>'+BASE64_HTTP_Icon+'</td><td><b>&nbsp;Error 404</b></td></tr></table><font size=+1><br>';

      //404 Fehler
      if (Length(GetFile)<>0) and (RightStr(Edit1.Text+GetFile,1)<>'\') then
        AResponseInfo.ContentText:=AResponseInfo.ContentText+'File "'+StringReplace(ComboBox1.Text+'/'+GetFile,'\','/',[rfReplaceAll, rfIgnoreCase])+'" not found<br><br>'
      else
        begin
          if DirectoryExists(StringReplace(Edit1.Text+GetFile,'/','\',[rfReplaceAll, rfIgnoreCase]))=true then
            AResponseInfo.ContentText:=AResponseInfo.ContentText+'Index file not found<br><br>'
          else
            AResponseInfo.ContentText:=AResponseInfo.ContentText+'URL http://'+ComboBox1.Text+'/'+StringReplace(GetFile,'\','/',[rfReplaceAll, rfIgnoreCase])+' not found<br><br>';
        end;

      //404 Directory
      if CheckBox1.Checked=true then
        begin
          FileList:=TStringList.Create;
          FileList.Clear;
          if RightStr(Edit1.Text+GetFile,1)='\' then
            FileList:=ListFiles(Edit1.Text+GetFile)
          else
            FileList:=ListFiles(ExtractFilePath(Edit1.Text+GetFile));
          if FileList.Count>0 then
            AResponseInfo.ContentText:=AResponseInfo.ContentText+'<table border="0"><tr>';
          for Counter:=0 to FileList.Count-1 do
            begin
              Buffer:=FileList.ValueFromIndex[Counter];
              if RightStr(Buffer,3)='../' then
                begin
                  AResponseInfo.ContentText:=AResponseInfo.ContentText+'<td><a href="http://'+ComboBox1.Text+'/'+Buffer+'">'+BASE64_Folder_Icon+'</a></td><td>&nbsp;<a href="http://'+ComboBox1.Text+'/'+Buffer+'">[directory up]</a></td><td></td></tr>'
                end
              else if RightStr(Buffer,2)='./' then
                begin
                  //AResponseInfo.ContentText:=AResponseInfo.ContentText+'<a href="http://'+ComboBox1.Text+'/'+Buffer+'">[dir]</a><br>'
                end
              else
                begin
                  if ExtractFilename(Buffer)<>'' then
                    AResponseInfo.ContentText:=AResponseInfo.ContentText+'<td><a href="http://'+ComboBox1.Text+'/'+Buffer+'">'+BASE64_File_Icon+'</a></td><td>&nbsp;<a href="http://'+ComboBox1.Text+'/'+Buffer+'">'+ExtractFilename(Buffer)+'</a></td><td>&nbsp;'+FileSizeToStr(FileSize(Edit1.Text+Buffer))+'</td></tr>'
                  else
                    AResponseInfo.ContentText:=AResponseInfo.ContentText+'<td><a href="http://'+ComboBox1.Text+'/'+Buffer+'">'+BASE64_Folder_Icon+'</a></td><td>&nbsp;<a href="http://'+ComboBox1.Text+'/'+Buffer+'">'+StringReplace(GetLastFolder(Buffer),'/','',[rfReplaceAll, rfIgnoreCase])+'</a></td><td></td></tr>'
                end;
            end;
        end;
      if FileList.Count>0 then
        AResponseInfo.ContentText:=AResponseInfo.ContentText+'</table>';

      //404 Footer
      //AResponseInfo.ContentText:=AResponseInfo.ContentText+'<br><br><br><font size=-1>Error page generated at '+TimeToStr(Time)+'<br>by <a href="http://'+ComboBox1.Text+':'+SpinEdit1.Text+'">'+Application.Title+' V'+ApplicationVersion+'</a> '+STR_Copyright_HTML+'<br><br></body></html>';
      AResponseInfo.ContentText:=AResponseInfo.ContentText+'<br><br><br><font size=-1>Error page generated at '+TimeToStr(Time)+'<br>by <a href="http://github.com/feuster/MiniHTTP/">'+Application.Title+' V'+ApplicationVersion+'</a> '+STR_Copyright_HTML+'<br><br></body></html>';

      AResponseInfo.RawHeaders.Clear;
      AResponseInfo.RawHeaders.Add('Cache-Control: no-store, no-cache, must-revalidate');
      AResponseInfo.RawHeaders.Add('Cache-Control: post-check=0, pre-check=0');
      AResponseInfo.RawHeaders.Add('Pragma: no-cache');
      if (RightStr(GetFile,1)<>'\') and (LocalFile='') then
        begin
          Print('Sende Fehler 404');
          AResponseInfo.ResponseNo:=404;
          AResponseInfo.ResponseText:='404 Not found';
        end
      else
        begin
          AResponseInfo.ResponseNo:=200;
          AResponseInfo.ResponseText:='200 OK';
        end;
      AResponseInfo.ServerSoftware:=Application.Title+' Server V'+ApplicationVersion;
      AResponseInfo.Server:=ComboBox1.Text;
      AResponseInfo.WriteHeader;
      AResponseInfo.WriteContent;
    end;

  except
    on E:Exception do
    begin
      Print('Fehler: "'+E.Message+'" ist in IdHTTPServer1CommandGet("'+ARequestInfo.Document+'") aufgetreten!');
    end;
  end;
end;

procedure TForm1.Label4Click(Sender: TObject);
//Server Inhalt optional anzeigen
begin
  CheckBox1.Checked:=not CheckBox1.Checked;
end;

procedure TForm1.Memo1Change(Sender: TObject);
//Memo Cursor ausblenden
begin
  if Memo1.Lines.Count>1000 then
    Memo1.Lines.Delete(0);
  SendMessage(Memo1.Handle,WM_VSCROLL,SB_BOTTOM,0);
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1Click(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1DblClick(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1EditingDone(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1Enter(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1Exit(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//Memo Cursor ausblenden
begin
    HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1KeyPress(Sender: TObject; var Key: char);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//Memo Cursor ausblenden
begin
    HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1MouseEnter(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1MouseLeave(Sender: TObject);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  //Memo Cursor ausblenden
  begin
    HideCaret(Memo1.Handle);
end;

procedure TForm1.Memo1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
//Memo Cursor ausblenden
begin
  HideCaret(Memo1.Handle);
end;

end.

