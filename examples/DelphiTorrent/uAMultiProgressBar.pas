{*_* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       AvtorFile
Creation:     2015
Version:      2.00
Description:  TAMultiProgressBar is a segmented progress bar.
EMail:        avtorfile@mail.ru         http://www.avtorfile.ru
Support:      Follow "support" link at http://www.avtorfile.ru for subscription.
Legal issues: Copyright (C) 2015 by AvtorFile
              <avtorfile@mail.ru>

              This software is provided 'as-is', without any express or
              implied warranty.  In no event will the author be held liable
              for any  damages arising from the use of this software.

              Permission is granted to anyone to use this software for any
              purpose, including commercial applications, and to alter it
              and redistribute it freely, subject to the following
              restrictions:

              1. The origin of this software must not be misrepresented,
                 you must not claim that you wrote the original software.
                 If you use this software in a product, an acknowledgment
                 in the product documentation would be appreciated but is
                 not required.

              2. Altered source versions must be plainly marked as such, and
                 must not be misrepresented as being the original software.

              3. This notice may not be removed or altered from any source
                 distribution.

              4. You must register this software by sending a picture postcard
                 to the author. Use a nice stamp and mention your name, street
                 address, EMail address and any comment you like to say.

Updates:
May 2015 - V2.00 - Arno added FireMonkey cross platform support with POSIX/MacOS
                   also IPv6 support, include files now in sub-directory


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit uAMultiProgressBar;

interface

{$B-}                  { Enable partial boolean evaluation   }
{$T-}                  { Untyped pointers                    }
{$X+}                  { Enable extended syntax              }
{$IFDEF COMPILER14_UP}
  {$IFDEF NO_EXTENDED_RTTI}
    {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
  {$ENDIF}
{$ENDIF}
{$IFDEF DELPHI6_UP}
    {$WARN SYMBOL_PLATFORM   OFF}
    {$WARN SYMBOL_LIBRARY    OFF}
    {$WARN SYMBOL_DEPRECATED OFF}
{$ENDIF}
{$IFDEF COMPILER2_UP}  { Not for Delphi 1                    }
    {$H+}              { Use long strings                    }
    {$J+}              { Allow typed constant to be modified }
{$ENDIF}
{$IFDEF BCB3_UP}
    {$ObjExportAll On}
{$ENDIF}

uses
  {$IFDEF RTL_NAMESPACES}System.SysUtils{$ELSE}SysUtils{$ENDIF},
  {$IFDEF RTL_NAMESPACES}System.Classes{$ELSE}Classes{$ENDIF},
  {$IFDEF RTL_NAMESPACES}Vcl.Controls{$ELSE}Controls{$ENDIF},
  {$IFDEF RTL_NAMESPACES}Vcl.ExtCtrls{$ELSE}ExtCtrls{$ENDIF},
  {$IFDEF RTL_NAMESPACES}Vcl.Graphics{$ELSE}Graphics{$ENDIF};

const
    MultiProgressBarVersion = 200;
    CopyRight : String      = ' TAMultiProgressBar ' +
                              '(c) 2015 AvtorFile V2.00 ';

type
  TMyShape = class(TShape)
  protected
    FStartPos : Int64;
    FCurPos   : Int64;
    FSpan     : Int64;
  end;

  TAMultiProgressBar = class(TCustomPanel)
  protected
    FSegments     : array of TMyShape;
    FTotalSpan    : Int64;
    procedure Resize; override;
    function  GetSegmentCount: Integer;
    procedure ResizeShapes;
  public
    constructor Create(AOwner : TComponent); override;
    function AddSegment(StartPos : Int64;
                        ASpan    : Int64;
                        InitPos  : Int64;
                        AColor   : TColor;
                        WColor   : TColor) : Integer;
    procedure SetPosition(SegmentIndex : Integer;
                          NewValue     : Int64;
                          AColor   : TColor;
                          WColor   : TColor);
    procedure Clear;
  published
    property SegmentCount : Integer read  GetSegmentCount;
    property Color;
    property Align;
  end;

implementation


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
constructor TAMultiProgressBar.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    BevelOuter := bvLowered;
    Caption    := '';
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TAMultiProgressBar.AddSegment(
    StartPos : Int64;
    ASpan    : Int64;
    InitPos  : Int64;
    AColor   : TColor;
    WColor   : TColor) : Integer;
var
    Sh     : TMyShape;
begin
    Result := Length(FSegments);
    SetLength(FSegments, Result + 1);

    Sh                := TMyShape.Create(Self);
    Sh.Parent         := Self;
    Sh.Shape          := stRectangle;
    Sh.Pen.Style      := psClear;
//    Sh.Brush.Color    := AColor;
    Sh.Top            := 1;
    Sh.Height         := Height - 1;
    Sh.FSpan          := ASpan;
    Sh.FStartPos      := FTotalSpan;
    Sh.FCurPos        := InitPos;
    if Sh.FCurPos <> Sh.FStartPos then
    begin
      Sh.Brush.Color    := AColor;
    end
    else
    begin
      Sh.Brush.Color    := WColor;
    end;
    FTotalSpan        := FTotalSpan + ASpan;
    FSegments[Result] := Sh;
    ResizeShapes;
end;

procedure TAMultiProgressBar.ResizeShapes;
var
    Offset : int64;//Integer;
    I      : Integer;
    Sh     : TMyShape;
begin
    Offset := 0;
    for I := 0 to Length(FSegments) - 1 do begin
        Sh       := FSegments[I];
        Sh.Left  := 1 + Round(1.0 * (Width - 2) * Offset / FTotalSpan);
        Sh.Width := 1 + Round(1 + (Width - 2) * (Sh.FCurPos - Sh.FStartPos) /
                    FTotalSpan);
        if (Sh.Left + Sh.Width) > Width then
            Sh.Width := Width - Sh.Left;
        Offset   := Offset + Sh.FSpan;
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TAMultiProgressBar.GetSegmentCount: Integer;
begin
    Result := Length(FSegments);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAMultiProgressBar.SetPosition(
    SegmentIndex : Integer;
    NewValue     : Int64;
    AColor   : TColor;
    WColor   : TColor);
var
    Sh : TMyShape;
begin
    if (SegmentIndex < 0) or (SegmentIndex >= GetSegmentCount) then
        raise ERangeError.Create('MultiProgressBar.SetPosition: Index out of range');
    Sh         := FSegments[SegmentIndex];
    if Sh.FCurPos <> Sh.FStartPos then
    begin
      Sh.Brush.Color    := AColor;
    end
    else
    begin
      Sh.Brush.Color    := WColor;
    end;
    Sh.FCurPos := NewValue;
    Sh.Width   := 1 + Round(1 + (Width - 2) * (Sh.FCurPos - Sh.FStartPos) /
                  FTotalSpan);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAMultiProgressBar.Clear;
var
    I : Integer;
begin
    for I := GetSegmentCount - 1 downto 0 do
        FreeAndNil(FSegments[I]);
    SetLength(FSegments, 0);
    FTotalSpan := 0;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TAMultiProgressBar.Resize;
begin
    inherited;
    ResizeShapes;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

end.
