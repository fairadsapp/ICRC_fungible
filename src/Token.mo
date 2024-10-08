import Buffer "mo:base/Buffer";
import D "mo:base/Debug";
import ExperimentalCycles "mo:base/ExperimentalCycles";

import Principal "mo:base/Principal";
import Time "mo:base/Time";

import CertifiedData "mo:base/CertifiedData";
import Nat64 "mo:base/Nat64";
import CertTree "mo:cert/CertTree";

import ICRC1 "mo:icrc1-mo/ICRC1";
import Account "mo:icrc1-mo/ICRC1/Account";
import ICRC2 "mo:icrc2-mo/ICRC2";
import ICRC3 "mo:icrc3-mo/";
import ICRC4 "mo:icrc4-mo/ICRC4";

///Custom ICDevs Token Code
import Types "Types";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Int "mo:base/Int";
import ICPTypes "ICPTypes";


shared ({ caller = _owner }) actor class Token  (args: ?{
    icrc1 : ?ICRC1.InitArgs;
    icrc2 : ?ICRC2.InitArgs;
    icrc3 : ICRC3.InitArgs; //already typed nullable
    icrc4 : ?ICRC4.InitArgs;
  }
) = this{
    let Set = ICRC1.Set;

    let default_icrc1_args : ICRC1.InitArgs = {
      name = ?"FairPANN";
      symbol = ?"FPNN";
      logo = ?"data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/PjwhRE9DVFlQRSBzdmcgIFBVQkxJQyAnLS8vVzNDLy9EVEQgU1ZHIDIwMDEwOTA0Ly9FTicgICdodHRwOi8vd3d3LnczLm9yZy9UUi8yMDAxL1JFQy1TVkctMjAwMTA5MDQvRFREL3N2ZzEwLmR0ZCc+PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEuMCIgd2lkdGg9IjkwMC4wMDAwMDBwdCIgaGVpZ2h0PSI5MDAuMDAwMDAwcHQiIHZpZXdCb3g9IjAgMCA5MDAuMDAwMDAwIDkwMC4wMDAwMDAiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIG1lZXQiPjxyZWN0IHg9IjAiIHk9IjAiIHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9IndoaXRlIi8+CjxtZXRhZGF0YT4KQ3JlYXRlZCBieSBwb3RyYWNlIDEuMTAsIHdyaXR0ZW4gYnkgUGV0ZXIgU2VsaW5nZXIgMjAwMS0yMDExCjwvbWV0YWRhdGE+CjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAuMDAwMDAwLDkwMC4wMDAwMDApIHNjYWxlKDAuMTAwMDAwLC0wLjEwMDAwMCkiIGZpbGw9IiMwMDAwMDAiIHN0cm9rZT0ibm9uZSI+CjxwYXRoIGQ9Ik02Mzg1IDg2MDAgYy0yNyAtNSAtOTAgLTkgLTEzOSAtOSAtNDkgLTEgLTEwMyAtNSAtMTIwIC0xMCAtMTcgLTUgLTUxIC0xNSAtNzYgLTIyIC03MSAtMjAgLTIxOSAtOTkgLTI1NyAtMTM4IC01MyAtNTUgLTczIC0xMDEgLTczIC0xNzEgMCAtMzMgLTcgLTc3IC0xNSAtOTcgLTggLTE5IC0xNSAtNjMgLTE1IC05NyAwIC0zNCAtNSAtNjcgLTEyIC03NCAtNiAtNiAtMTEgLTMyIC0xMCAtNTcgMSAtMjQgLTMgLTY0IC05IC04NyAtMjUgLTkzIC00OSAtMzcxIC0zOSAtNDQzIDkgLTY5IDUzIC0xNDQgMTAxIC0xNzIgMTYgLTkgMjkgLTIxIDI5IC0yNiAwIC0xMCAyMjcgLTExOSAzNjAgLTE3MyAyNSAtMTAgNTIgLTI0IDYxIC0zMSA4IC03IDIzIC0xMyAzMiAtMTMgOSAwIDE4IC00IDIyIC0xMCAzIC01IDM4IC0yNSA3OCAtNDUgODUgLTQxIDE4NyAtMTAwIDE5NiAtMTEyIDMgLTUgMjAgLTE3IDM2IC0yNyA2NyAtNDIgMjg1IC0yNDIgMjg1IC0yNjEgMCAtNyA5IC0yMCAyMCAtMzAgMjcgLTI1IDg2IC0xMTMgMTM1IC0yMDAgNDMgLTc4IDc1IC0xMjUgODYgLTEyNSA0IDAgMTQgMTkgMjQgNDMgNDQgMTEyIDE4MyAyODUgMjgzIDM1MiAyMCAxNCA1NiA0MCA3OCA1OCAyMyAxNyA2MSA0NiA4NSA2NCAxMTggODUgMjQwIDE5MyAyNTAgMjIyIDUgMTMgMTAgMTU1IDEwIDMxNyAwIDI0MSAtMyAyOTkgLTE2IDMzMCAtOCAyMCAtMTUgNTMgLTE1IDczIDAgMjAgLTcgNDUgLTE1IDU1IC04IDExIC0xNSAzMiAtMTUgNDcgMCAzMiAtNTggMTgwIC0xMDEgMjU5IC01IDggLTE1IDI5IC0yMyA0NiAtNyAxNyAtMjcgNDYgLTQzIDY1IC0xNiAxOSAtMzcgNDcgLTQ4IDY0IC0yOCA0NSAtMTI2IDE0NCAtMTY1IDE2NyAtMTkgMTIgLTQ1IDMwIC01NiA0MCAtNDIgMzggLTE5OSAxMTkgLTI4NCAxNDggLTEzNyA0NiAtMTk0IDU3IC0zNjAgNjkgLTYzIDUgLTEzNyAxMSAtMTY1IDE0IC0yNyAzIC03MiAyIC0xMDAgLTN6Ii8+CjxwYXRoIGQ9Ik0yMjQ1IDg0OTkgYy0xNDEgLTEwIC0yMTkgLTIyIC0yMzYgLTM2IC04IC02IC0yNyAtMTMgLTQ0IC0xNiAtODAgLTE0IC0zMDIgLTEyMCAtMzc1IC0xNzcgLTIxIC0xNyAtNDIgLTMwIC00NyAtMzAgLTEyIDAgLTE0NyAtMTQxIC0xNzAgLTE3NyAtOSAtMTYgLTI1IC0zOCAtMzYgLTUwIC0yNCAtMjcgLTMxIC00MCAtOTUgLTE2OCAtMjcgLTU1IC01MyAtMTExIC01NiAtMTI1IC00IC0xNCAtMTEgLTM0IC0xNSAtNDUgLTEyIC0yOCAtMzMgLTEyMyAtMzggLTE2NSAtMiAtMTkgLTkgLTQwIC0xNSAtNDcgLTE0IC0xOCAtMTQgLTU4OCAwIC02MjQgMTggLTQ1IDcxIC05OCAxODcgLTE4NCA2MCAtNDUgMTE5IC05MiAxMjkgLTEwNCAxMSAtMTEgMjMgLTIxIDI4IC0yMSA2IDAgMzMgLTIwIDYxIC00NSAyOSAtMjUgNTYgLTQ1IDYyIC00NSAxMiAwIDE0NSAtMTMyIDE0NSAtMTQzIDAgLTUgMTEgLTIzIDI1IC00MSAxMyAtMTggMzkgLTU5IDU2IC05MiA0OSAtOTQgNTIgLTk1IDkyIC0zMiAxOSAzMCAzOCA2NCA0MSA3NiA0IDEyIDEyIDIyIDE3IDIyIDUgMCA5IDYgOSAxMyAwIDcgMzggNjYgODUgMTMwIDQ3IDY0IDg1IDEyMSA4NSAxMjYgMCAxNCA5MCAxMDEgMTA0IDEwMSA3IDAgMjEgMTAgMzIgMjEgMjQgMjcgMTMxIDEwOCAxNTIgMTE3IDkgMyA0MiAyMyA3MyA0NCA2MiA0MSAyMTYgMTE2IDM0NCAxNjggNDQgMTggODcgMzkgOTYgNDYgOCA4IDIzIDE0IDMxIDE0IDkgMCAxOCA3IDIyIDE1IDMgOCAxNCAxNSAyNSAxNSAyMiAwIDcyIDI3IDE0MyA3OCA0NiAzMyAxMDQgMTA3IDExNCAxNDcgMTQgNTQgLTE1IDQyOCAtMzMgNDQ3IC04IDcgLTEzIDM5IC0xMyA4MyAwIDQ1IC01IDc4IC0xNCA5MSAtOCAxMSAtMTcgNTMgLTIwIDk0IC0xOSAyNjkgLTM2IDMxMSAtMTYxIDM5MiAtNTMgMzQgLTE4MiA5NSAtMjIwIDEwMyAtMTYgNCAtNDEgMTAgLTU1IDE1IC0zNiAxMiAtMzg3IDE5IC01MTUgOXoiLz4KPHBhdGggZD0iTTU0NTUgNjQwOCBjLTE2IC01IC02MyAtMjYgLTEwMyAtNDUgLTcxIC0zNCAtNzUgLTM5IC0xMDYgLTEwMiAtMTggLTM2IC02OSAtMTM4IC0xMTMgLTIyNiAtMTYwIC0zMTggLTIxMyAtNDM2IC0yMTMgLTQ4MSAwIC0xMSAtNyAtMjkgLTE1IC00MCAtMjIgLTI5IC0yMSAtMjUwIDIgLTMwMSAzMCAtNjkgNzQgLTE1NyA5NyAtMTk2IDEyIC0yMCAxNDUgLTE1OSAyOTQgLTMwNyAxNTAgLTE0OSAyNzIgLTI3NSAyNzIgLTI4MCAwIC01IDEzIC0yNCAyOCAtNDIgNzcgLTg5IDIxMiAtMzgyIDIxMiAtNDYxIDAgLTEzIDUgLTI4IDEwIC0zMyA2IC02IDEzIC0zNyAxNiAtNzAgMiAtMzIgOCAtNjYgMTEgLTc0IDQgLTggMTAgLTU4IDEzIC0xMTAgNSAtOTQgNSAtOTUgMzAgLTkzIDY0IDYgMTQ4IDIxIDE2OCAzMiAxMSA2IDMxIDExIDQ0IDExIDI3IDAgMjI5IDY3IDI0MyA4MSA1IDUgMTYgOSAyNSA5IDkgMCAzNyAxMSA2MSAyNSAyNCAxNCA1MSAyOCA1OSAzMiA3OSAzOCAyNjMgMjA5IDMxMiAyODkgMzUgNTYgODggMTczIDg4IDE5MSAwIDExIDUgMjQgMTEgMzAgMjEgMjEgMzIgMTMyIDMyIDMxOCAwIDE5MiAtMTAgMzAzIC0zMSAzNDIgLTcgMTIgLTEyIDM3IC0xMiA1NyAwIDE5IC00IDM4IC0xMCA0MSAtNSAzIC0xMCAxNSAtMTAgMjUgMCAyNiAtNjggMjMwIC04NiAyNTcgLTggMTIgLTE0IDI4IC0xNCAzNSAwIDE3IC00MiAxMjAgLTkxIDIyNCAtMjcgNTggLTQ4IDg5IC03NiAxMDkgLTIxIDE2IC05NSA4MyAtMTY0IDE0OSAtNjkgNjcgLTE5NSAxODQgLTI3OCAyNjEgLTg0IDc3IC0xNjIgMTUzIC0xNzMgMTY4IC0zNiA1MCAtMTY2IDEzOCAtMjQwIDE2MyAtNTYgMTkgLTkwIDI0IC0xNjYgMjMgLTU0IC0xIC0xMTAgLTYgLTEyNyAtMTF6IG02MzYgLTkyOSBjODggLTQ0IDE1NiAtMTE1IDE3MyAtMTgxIDMgLTE2IDExIC0yOCAxNiAtMjggNiAwIDEwIC0zNiAxMCAtODQgMCAtNzIgLTQgLTkzIC0zMCAtMTQ4IC0zNyAtNzkgLTEyMSAtMTY1IC0xNzYgLTE4MCAtMjEgLTYgLTcxIC0xMyAtMTEwIC0xNSAtNjQgLTQgLTc5IC0xIC0xMzUgMjUgLTkzIDQ0IC0xNjQgMTI3IC0xODQgMjE3IC0xNCA1OSAtMTcgMTQ3IC02IDE1OCA2IDYgMTEgMTkgMTEgMjkgMCAzMiAzNiA5MSA4NCAxMzggMTA4IDEwNCAyMjcgMTI4IDM0NyA2OXoiLz4KPHBhdGggZD0iTTMxNDkgNjM3NCBjLTEwMiAtMzcgLTE1OSAtODAgLTMzMyAtMjUyIC04OSAtODggLTE5NyAtMTkwIC0yNDEgLTIyOCAtNDQgLTM4IC05OCAtODggLTEyMCAtMTEzIC0yMiAtMjQgLTc4IC03NiAtMTI1IC0xMTYgLTEwMSAtODYgLTExNyAtMTEyIC0yMDAgLTM0NSAtMTkgLTUyIC0yNiAtNzAgLTQ5IC0xMjkgLTEyIC0yOSAtMjEgLTYxIC0yMSAtNzAgMCAtOSAtNyAtMjkgLTE1IC00NSAtOCAtMTUgLTE1IC00MSAtMTUgLTU2IDAgLTE1IC03IC0zMyAtMTUgLTQwIC04IC03IC0xNSAtMjggLTE1IC00NyAwIC0xOSAtNSAtNDQgLTEyIC01NiAtMTkgLTM2IC0zMCAtMTQ0IC0zNSAtMzM2IC0yIC0xMjAgMCAtMTg4IDcgLTE5NSA1IC01IDEwIC0yNiAxMCAtNDUgMCAtMjAgNyAtNDkgMTUgLTY1IDggLTE1IDE1IC0zNCAxNSAtNDEgMCAtOCA2IC0yNiAxNCAtNDIgOCAtMTUgMjMgLTQ2IDMzIC02OCA3MiAtMTU1IDI2MiAtMzM1IDQ0NSAtNDE4IDIwIC05IDQxIC0xNyA0NyAtMTcgNyAwIDIyIC02IDM0IC0xNCAxMiAtNyA0NyAtMjEgNzcgLTMxIDMwIC05IDY5IC0yMSA4NSAtMjcgMTcgLTYgNDggLTE0IDcwIC0xOCAyMiAtNCA1NiAtMTMgNzUgLTE5IDE5IC02IDQ3IC0xMSA2MyAtMTEgMTUgMCAzNiAtNSA0NiAtMTIgMzcgLTIzIDQ5IDMgNTUgMTE1IDEyIDI0MyA3MiA0NDkgMTgwIDYyMiAxNCAyMiAzMSA1MCAzOCA2MiA0OCA4MCAxMTUgMTU2IDMzNCAzNzMgMjkyIDI5MCAzMzkgMzUwIDM4OSA0OTIgMTcgNTAgMjEgMjkzIDUgMzAzIC01IDMgLTEwIDE5IC0xMCAzNSAwIDE2IC04IDQ2IC0xNyA2NyAtNTUgMTIyIC0xODAgMzgyIC0yNTkgNTM3IGwtOTAgMTc5IC02NSAzNSBjLTgxIDQ0IC0xMjEgNTQgLTIzOSA1OCAtODAgMiAtMTA1IC0xIC0xNjEgLTIyeiBtLTEzMyAtODQ5IGMxMCAtOCAyNyAtMTUgMzggLTE1IDUyIC0xIDE0NyAtODYgMTk0IC0xNzQgMjggLTUyIDMyIC02OSAzMiAtMTM1IDAgLTY0IC01IC04NSAtMzAgLTEzNiAtMzcgLTc1IC05NiAtMTM0IC0xNzQgLTE3NCAtNDkgLTI2IC02OSAtMzEgLTEzMiAtMzEgLTE1NiAwIC0yNzggOTYgLTMzMiAyNjEgLTE2IDQ5IC0xNCAxMzAgMyAxNTMgOCAxMSAxNSAyOSAxNSA0MCAwIDU4IDEwNSAxNjQgMTg4IDE5MSAyOSAxMCA1NSAyMSA1OCAyNiA5IDE1IDExOCAxMCAxNDAgLTZ6Ii8+CjxwYXRoIGQ9Ik0zMzQyIDM5MTEgYy0xMCAtNiAtMTIgLTI3IC04IC04MiA5IC0xMjggMjIgLTIyMyAzNCAtMjQ2IDcgLTEyIDEyIC0zMSAxMiAtNDIgMCAtNDYgNjQgLTE1NyAxMjkgLTIyNSA2MiAtNjQgMTQxIC0xMTYgMTc2IC0xMTYgOSAwIDIzIC03IDMxIC0xNSA5IC04IDI3IC0xNSA0MiAtMTUgMTQgMCAzOSAtNCA1NiAtOSAxNyAtNSA1NiAtMTUgODYgLTIxIDE2NyAtMzUgMjk3IC0xMDAgMzg1IC0xOTIgNDggLTQ5IDc2IC03MCAxMDggLTc5IDIzIC03IDUxIC0xOSA2MiAtMjYgMjkgLTE5IDYxIC0xNiAxMzQgMTMgNjcgMjcgMTExIDU4IDExMSA3OSAwIDM3IDE2MyAxNTEgMzA3IDIxNSAzNyAxNyA3NiAzNSA4NSA0MCAxMCA2IDI4IDEwIDQwIDEwIDEzIDEgMzQgNyA0OCAxNSAxNCA4IDMzIDE0IDQzIDE1IDI0IDAgMTkxIDgzIDIzMyAxMTUgODQgNjQgMTUxIDI0OCAxNTYgNDMzIDIgNzQgMCA5NSAtMTIgMTAyIC0xOSAxMyAtNDY2IDYgLTU0MCAtOCAtODkgLTE2IC0yNjQgLTcyIC0zMjAgLTEwMiAtNTcgLTMxIC0yMjUgLTcyIC0yNTIgLTYxIC0xMiA0IC03MCAxMSAtMTI4IDE1IC05NSA2IC0yMjcgMzYgLTI1NiA1OCAtMTMgMTAgLTEzNCA1NiAtMTg0IDcwIC04NCAyMyAtMTE5IDMwIC0xOTAgMzcgLTQxIDUgLTg4IDEzIC0xMDMgMjAgLTMzIDEzIC0yNjUgMTUgLTI4NSAyeiIvPgo8cGF0aCBkPSJNMTAxNyAzNTc2IGMtNCAtMTAgLTcgLTI5OSAtNyAtNjQzIGwwIC02MjUgMTA4IC0xMDcgYzEyNSAtMTIzIDM0NyAtMzA1IDM2MiAtMjk2IDYgNCAxMCAxNjUgMTAgNDU2IGwwIDQ0OSAtOTUgMTAyIGMtMTQ4IDE1NyAtMjMwIDI5NCAtMzA5IDUxMyAtNjcgMTg2IC02MSAxNzIgLTY5IDE1MXoiLz4KPHBhdGggZD0iTTc5MjYgMzQxMiBjLTY5IC0yMDYgLTIxNyAtNDMxIC0zODEgLTU3OCBsLTc1IC02NiAwIC00NDUgYzAgLTQ5MSAtMiAtNDc3IDYyIC00MzIgODcgNjIgMjQzIDE5MyAzMzYgMjgzIGwxMDIgOTkgMCA2MDMgYzAgMzU0IC00IDYwNSAtOSA2MDggLTUgNCAtMjEgLTI5IC0zNSAtNzJ6Ii8+CjxwYXRoIGQ9Ik00NDI1IDI4MTEgYy0yOCAtNSAtNTUgLTIyIC04OSAtNTQgLTExMiAtMTA3IC0zNDUgLTEzNiAtNTgyIC03MSAtODggMjMgLTk4IDI0IC0xMTIgMTAgLTM3IC0zNyA1MCAtMTQxIDE5MiAtMjMxIDEzOCAtODcgMzAzIC0xNDQgNTAwIC0xNzAgMTM3IC0xOSAyMjMgLTE5IDM1MiAwIDI1OCAzNiA0NzIgMTI4IDYxMCAyNjAgNzcgNzQgOTggMTE1IDcyIDE0MSAtMTMgMTMgLTIyIDEzIC03NCAtMiAtMzIgLTggLTc3IC0yMSAtOTkgLTI3IC0yMiAtNSAtMTAxIC0xMSAtMTc1IC0xMSAtMTA4IC0xIC0xNDcgMyAtMTk1IDE4IC03MiAyNCAtMTI3IDU2IC0xNjkgMTAxIC0yOSAzMiAtMzYgMzQgLTExMSAzOSAtNDQgMiAtOTggMSAtMTIwIC0zeiIvPgo8cGF0aCBkPSJNMjAwMCAyMDI1IGwwIC00NTUgMjMgLTE0IGM5NCAtNjIgNDU2IC0yMzkgNDc0IC0yMzIgMTEgNCAxMyA5MSAxMyA0NzAgbDAgNDY2IC0yMiAxNCBjLTEzIDggLTY2IDMxIC0xMTggNTEgLTUyIDIxIC0xNTEgNjQgLTIxOSA5NiAtNjggMzMgLTEyOSA1OSAtMTM3IDU5IC0xMiAwIC0xNCAtNzQgLTE0IC00NTV6Ii8+CjxwYXRoIGQ9Ik02ODIwIDI0MDMgYy01MiAtMjUgLTE1MSAtNjcgLTIyMCAtOTQgLTY5IC0yNyAtMTMyIC01MyAtMTQwIC01OCAtMTMgLTcgLTE1IC03MyAtMTggLTQ4MCAtMiAtNDE0IDAgLTQ3MiAxMyAtNDc3IDkgLTQgMTE4IDQ1IDI1MyAxMTIgMTc3IDg5IDI0MCAxMjUgMjQ5IDE0NCA5IDE5IDEzIDEzMyAxMiA0NDggMCAyMzMgLTMgNDMwIC02IDQzOCAtOSAyMyAtNDIgMTUgLTE0MyAtMzN6Ii8+CjxwYXRoIGQ9Ik0zMDI1IDIwNzggYy0zIC03IC00IC0yMzYgLTMgLTUwOCBsMyAtNDk1IDM1IC0xNyBjMTAwIC01MSAzNzAgLTE3OCAzNzYgLTE3OCAxMyAwIDczMCAtMzYzIDg1OSAtNDM1IDcyIC00MCAxNDggLTgyIDE3MCAtOTMgbDQxIC0yMCA0OSAyNSBjNDkgMjQgMTQzIDc2IDIxNSAxMTcgNzQgNDIgNTk1IDMwNSA3MzAgMzY4IDIzOSAxMTIgMzg3IDE4MyA0MDggMTk2IGwyMiAxNCAtMiA1MDIgLTMgNTAxIC0yNSAtMSBjLTE0IDAgLTgxIC0xOCAtMTUwIC0zOCAtNjkgLTIxIC0xNDcgLTQ0IC0xNzUgLTUyIC0yNyAtOCAtNjMgLTE5IC04MCAtMjQgLTM5IC0xMiAtNjQxIC0xNjYgLTcyNSAtMTg2IC0zNiAtOCAtODMgLTE5IC0xMDUgLTIzIC0yMiAtNSAtNTMgLTEzIC02OCAtMjAgLTM5IC0xNSAtMTM0IC0xNCAtMTg4IDMgLTI0IDcgLTc1IDIxIC0xMTQgMzAgLTE2MyAzNyAtNTM1IDEyOSAtNjAwIDE0NyAtMzggMTAgLTk3IDI3IC0xMzAgMzUgLTMzIDkgLTc4IDIyIC0xMDAgMjkgLTQ2IDE1IC05OSAzMSAtMjc1IDgyIC02OSAxOSAtMTMzIDQwIC0xNDMgNDUgLTEyIDYgLTE5IDUgLTIyIC00eiIvPgo8L2c+Cjwvc3ZnPg==";
      decimals = 8;
      // Fee-ul sa fie cat mai mic posibil, ramane asa fix si 0.1
      fee = ?#Fixed(10000);

      // IRC20 sa fie facut ca sa putem adauga id-ul portofelului in Metamask
      // 1. Mintingul o sa fie unul singur initial precum in document
        // Functia de mint trebuie modificata astfel: Pentru fiecare portofel din document baga numarul de tokeni(Precizat in document) in id-ul portofelului.
      // 2. We do need a liquidity pool for swapping between tokens(Inclus in 1. prima observatie deoarece este tot un id de portofel)
      // 3. Neaparat fara burn
      minting_account = ?{
        owner = _owner;
        subaccount = null;
      };
      max_supply = null;
      min_burn_amount = null;
      max_memo = ?64;
      advanced_settings = null;
      metadata = null;
      fee_collector = null;
      transaction_window = null;
      permitted_drift = null;
      // Fa-l 100 miliarde
      max_accounts = ?100000000;
      settle_to_accounts = ?99999000;
    };

    let default_icrc2_args : ICRC2.InitArgs = {
      max_approvals_per_account = ?10000;
      max_allowance = ?#TotalSupply;
      fee = ?#ICRC1;
      advanced_settings = null;
      max_approvals = ?10000000;
      settle_to_approvals = ?9990000;
    };

    let default_icrc3_args : ICRC3.InitArgs = ?{
      maxActiveRecords = 3000;
      settleToRecords = 2000;
      maxRecordsInArchiveInstance = 100000000;
      maxArchivePages = 62500;
      archiveIndexType = #Stable;
      maxRecordsToArchive = 8000;
      archiveCycles = 6_000_000_000_000;
      archiveControllers = null; //??[put cycle ops prinicpal here];
      supportedBlocks = [
        {
          block_type = "1xfer"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "2xfer"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "2approve"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "1mint"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        },
        {
          block_type = "1burn"; 
          url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
        }
      ];
    };

    let default_icrc4_args : ICRC4.InitArgs = {
      max_balances = ?200;
      max_transfers = ?200;
      fee = ?#ICRC1;
    };

    let icrc1_args : ICRC1.InitArgs = switch(args){
      case(null) default_icrc1_args;
      case(?args){
        switch(args.icrc1){
          case(null) default_icrc1_args;
          case(?val){
            {
              val with minting_account = switch(
                val.minting_account){
                  case(?val) ?val;
                  case(null) {?{
                    owner = _owner;
                    subaccount = null;
                  }};
                };
            };
          };
        };
      };
    };

    let icrc2_args : ICRC2.InitArgs = switch(args){
      case(null) default_icrc2_args;
      case(?args){
        switch(args.icrc2){
          case(null) default_icrc2_args;
          case(?val) val;
        };
      };
    };


    let icrc3_args : ICRC3.InitArgs = switch(args){
      case(null) default_icrc3_args;
      case(?args){
        switch(args.icrc3){
          case(null) default_icrc3_args;
          case(?val) ?val;
        };
      };
    };

    let icrc4_args : ICRC4.InitArgs = switch(args){
      case(null) default_icrc4_args;
      case(?args){
        switch(args.icrc4){
          case(null) default_icrc4_args;
          case(?val) val;
        };
      };
    };

    stable let icrc1_migration_state = ICRC1.init(ICRC1.initialState(), #v0_1_0(#id),?icrc1_args, _owner);
    stable let icrc2_migration_state = ICRC2.init(ICRC2.initialState(), #v0_1_0(#id),?icrc2_args, _owner);
    stable let icrc4_migration_state = ICRC4.init(ICRC4.initialState(), #v0_1_0(#id),?icrc4_args, _owner);
    stable let icrc3_migration_state = ICRC3.init(ICRC3.initialState(), #v0_1_0(#id), icrc3_args, _owner);
    stable let cert_store : CertTree.Store = CertTree.newStore();
    let ct = CertTree.Ops(cert_store);

    stable var owner = _owner;

    let #v0_1_0(#data(icrc1_state_current)) = icrc1_migration_state;

    private var _icrc1 : ?ICRC1.ICRC1 = null;

    private func get_icrc1_state() : ICRC1.CurrentState {
      return icrc1_state_current;
    };

    private func get_icrc1_environment() : ICRC1.Environment {
    {
      get_time = null;
      get_fee = null;
      add_ledger_transaction = ?icrc3().add_record;
      can_transfer = null; //set to a function to intercept and add validation logic for transfers
    };
  };

    func icrc1() : ICRC1.ICRC1 {
    switch(_icrc1){
      case(null){
        let initclass : ICRC1.ICRC1 = ICRC1.ICRC1(?icrc1_migration_state, Principal.fromActor(this), get_icrc1_environment());
        ignore initclass.register_supported_standards({
          name = "ICRC-3";
          url = "https://github.com/dfinity/ICRC/ICRCs/icrc-3/"
        });
        ignore initclass.register_supported_standards({
          name = "ICRC-10";
          url = "https://github.com/dfinity/ICRC/ICRCs/icrc-10/"
        });
        _icrc1 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc2_state_current)) = icrc2_migration_state;

  private var _icrc2 : ?ICRC2.ICRC2 = null;

  private func get_icrc2_state() : ICRC2.CurrentState {
    return icrc2_state_current;
  };

  private func get_icrc2_environment() : ICRC2.Environment {
    {
      icrc1 = icrc1();
      get_fee = null;
      can_approve = null; //set to a function to intercept and add validation logic for approvals
      can_transfer_from = null; //set to a function to intercept and add validation logic for transfer froms
    };
  };

  func icrc2() : ICRC2.ICRC2 {
    switch(_icrc2){
      case(null){
        let initclass : ICRC2.ICRC2 = ICRC2.ICRC2(?icrc2_migration_state, Principal.fromActor(this), get_icrc2_environment());
        _icrc2 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc4_state_current)) = icrc4_migration_state;

  private var _icrc4 : ?ICRC4.ICRC4 = null;

  private func get_icrc4_state() : ICRC4.CurrentState {
    return icrc4_state_current;
  };

  private func get_icrc4_environment() : ICRC4.Environment {
    {
      icrc1 = icrc1();
      get_fee = null;
      can_approve = null; //set to a function to intercept and add validation logic for approvals
      can_transfer_from = null; //set to a function to intercept and add validation logic for transfer froms
    };
  };

  func icrc4() : ICRC4.ICRC4 {
    switch(_icrc4){
      case(null){
        let initclass : ICRC4.ICRC4 = ICRC4.ICRC4(?icrc4_migration_state, Principal.fromActor(this), get_icrc4_environment());
        _icrc4 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

  let #v0_1_0(#data(icrc3_state_current)) = icrc3_migration_state;

  private var _icrc3 : ?ICRC3.ICRC3 = null;

  private func get_icrc3_state() : ICRC3.CurrentState {
    return icrc3_state_current;
  };

  func get_state() : ICRC3.CurrentState{
    return icrc3_state_current;
  };

  private func get_icrc3_environment() : ICRC3.Environment {
    ?{
      updated_certification = ?updated_certification;
      get_certificate_store = ?get_certificate_store;
    };
  };

  func ensure_block_types(icrc3Class: ICRC3.ICRC3) : () {
    let supportedBlocks = Buffer.fromIter<ICRC3.BlockType>(icrc3Class.supported_block_types().vals());

    let blockequal = func(a : {block_type: Text}, b : {block_type: Text}) : Bool {
      a.block_type == b.block_type;
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1xfer"; url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1xfer"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "2xfer"; url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "2xfer"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "2approve";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "2approve"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1mint";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1mint"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    if(Buffer.indexOf<ICRC3.BlockType>({block_type = "1burn";url="";}, supportedBlocks, blockequal) == null){
      supportedBlocks.add({
            block_type = "1burn"; 
            url="https://github.com/dfinity/ICRC-1/tree/main/standards/ICRC-3";
          });
    };

    icrc3Class.update_supported_blocks(Buffer.toArray(supportedBlocks));
  };

  func icrc3() : ICRC3.ICRC3 {
    switch(_icrc3){
      case(null){
        let initclass : ICRC3.ICRC3 = ICRC3.ICRC3(?icrc3_migration_state, Principal.fromActor(this), get_icrc3_environment());
        _icrc3 := ?initclass;
        ensure_block_types(initclass);

        initclass;
      };
      case(?val) val;
    };
  };

  private func updated_certification(cert: Blob, lastIndex: Nat) : Bool{

    // D.print("updating the certification " # debug_show(CertifiedData.getCertificate(), ct.treeHash()));
    ct.setCertifiedData();
    // D.print("did the certification " # debug_show(CertifiedData.getCertificate()));
    return true;
  };

  private func get_certificate_store() : CertTree.Store {
    // D.print("returning cert store " # debug_show(cert_store));
    return cert_store;
  };

  /// Functions for the ICRC1 token standard
  public shared query func icrc1_name() : async Text {
      icrc1().name();
  };

  public shared query func icrc1_symbol() : async Text {
      icrc1().symbol();
  };

  public shared query func icrc1_decimals() : async Nat8 {
      icrc1().decimals();
  };

  public shared query func icrc1_fee() : async ICRC1.Balance {
      icrc1().fee();
  };

  public shared query func icrc1_metadata() : async [ICRC1.MetaDatum] {
      icrc1().metadata()
  };

  public shared query func icrc1_total_supply() : async ICRC1.Balance {
      icrc1().total_supply();
  };

  public shared query func icrc1_minting_account() : async ?ICRC1.Account {
      ?icrc1().minting_account();
  };

  public shared query func icrc1_balance_of(args : ICRC1.Account) : async ICRC1.Balance {
      icrc1().balance_of(args);
  };

  public shared query func icrc1_supported_standards() : async [ICRC1.SupportedStandard] {
      icrc1().supported_standards();
  };

  public shared query func icrc10_supported_standards() : async [ICRC1.SupportedStandard] {
      icrc1().supported_standards();
  };

  public shared ({ caller }) func icrc1_transfer(args : ICRC1.TransferArgs) : async ICRC1.TransferResult {
      switch(await* icrc1().transfer_tokens(caller, args, false, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public shared ({ caller }) func mint(args : ICRC1.Mint) : async ICRC1.TransferResult {
      if(caller != owner){ D.trap("Unauthorized")};

      switch( await* icrc1().mint_tokens(caller, args)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  private func time64() : Nat64 {
    Nat64.fromNat(Int.abs(Time.now()));
  };

  // HERE MINT
  // Fa exact ce am discutat la punctul 1
  stable var bonus : Nat = 1000_0000_0000;
  stable var bonusDen : Nat = 1_0000_0000;
  stable var mintedCount = 0;
  stable var mintedGoal = 1_000_000_0000_0000;

  public shared ({ caller }) func mintFromICP(args : Types.MintFromICPArgs) : async ICRC1.TransferResult {

      if(args.amount < 1000000) {
        D.trap("Minimum mint amount is 0.01 PANN");
      };

      let ICPLedger : ICPTypes.Service = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");

      let result = try{
        await ICPLedger.icrc2_transfer_from({
          to = {
            owner = Principal.fromActor(this);
            subaccount = null;
          };
          fee = null;
          spender_subaccount = null;
          from = {
            owner = caller;
            subaccount = args.source_subaccount;
          };
          memo = ?Blob.toArray("\a4\c5\f0\4e\cc\e9\83\08\53\fc\7d\2b\e1\fe\ba\03\f1\e3\d6\2a\26\25\96\e3\bb\64\e2\ec\4d\20\36\13" : Blob); //"ICDevs Donation"
          created_at_time = ?time64();
          amount = args.amount-10000;
        });
      } catch(e){
        D.trap("cannot transfer from failed" # Error.message(e));
      };

      let block = switch(result){
        case(#Ok(block)) block;
        case(#Err(err)){
            D.trap("cannot transfer from failed" # debug_show(err));
        };
      };


      let mintingAmount = (bonus/bonusDen) * args.amount;
      mintedCount += mintingAmount;

      //recalculate bonus
      if(mintedCount > mintedGoal){
        bonus := bonus/2;
        mintedCount := 0;
      };

      let newtokens = await* icrc1().mint_tokens(Principal.fromActor(this), {
        to = switch(args.target){
            case(null){
              {
                owner = caller;
                subaccount = null;
              }
            };
            case(?val) {
              {
                owner = val.owner;
                subaccount = switch(val.subaccount){
                  case(null) null;
                  case(?val) ?Blob.fromArray(val);
                };
              }
            };
          };               // The account receiving the newly minted tokens.
        amount = mintingAmount;           // The number of tokens to mint.
        created_at_time = ?time64();
        memo = ?("\a4\c5\f0\4e\cc\e9\83\08\53\fc\7d\2b\e1\fe\ba\03\f1\e3\d6\2a\26\25\96\e3\bb\64\e2\ec\4d\20\36\13" : Blob); //"ICDevs Donation"
      });


      let treasurytokens = await* icrc1().mint_tokens(Principal.fromActor(this), {
        to = {
          owner = Principal.fromText("6b6d3-c6fka-fermk-mgfye-d2klj-krchc-ix2mt-6gl4i-ivb5c-czkvg-gae");
          subaccount = null;
        };               // The account receiving the newly minted tokens.}
        amount = mintingAmount;           // The number of tokens to mint.
        created_at_time = ?time64();
        memo = ?("\8b\dc\f7\7f\10\d0\47\a8\9c\1e\f9\45\b0\5a\9d\f5\7a\18\af\b3\e0\f2\a0\f0\7c\d8\d6\77\a6\e5\8c\27" : Blob); //"Treasury Mint"
      });

      return switch(newtokens){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };

  };

  public query func stats() : async { 
      mintedEpoch : Nat;
      bonusEpoch : Nat;
      bonusDenEpoch : Nat;
      mintedGoalEpoch : Nat;
      totalSupply : Nat;
      holders : Nat;
  }{
    return {
      mintedEpoch = mintedCount;
      bonusEpoch = bonus;
      bonusDenEpoch = bonusDen;
      mintedGoalEpoch = mintedGoal;
      totalSupply = icrc1().total_supply();
      holders = ICRC1.Map.size(icrc1().get_state().accounts);
    };
  };

  public query func holders(min:?Nat, max: ?Nat, prev: ?ICRC1.Account, take: ?Nat) : async  
    [(ICRC1.Account, Nat)]
  {

    let results = ICRC1.Vector.new<(ICRC1.Account, Nat)>();
    let (bFound_, targetAccount) = switch(prev){
      case(null) (true, {owner = Principal.fromActor(this); subaccount = null});
      case(?val) (false, val);
    };

    var bFound : Bool = bFound_;

    let takeVal = switch(take){
      case(null) 1000; //default take
      case(?val) val;
    };

    label search for(thisAccount in ICRC1.Map.entries(icrc1().get_state().accounts)){
      if(bFound){
        if(ICRC1.Vector.size(results) >= takeVal){
          break search;
        };
        
      } else {
        if(ICRC1.account_eq(targetAccount, thisAccount.0)){
          bFound := true;
        } else {
          continue search;
        };
      };
      let minSearch = switch(min){
        case(null) 0;
        case(?val) val;
      };
      let maxSearch = switch(max){
        case(null) 20_000_000_0000_0000;  //our max supply is far less than 20M
        case(?val) val;
      };
      if(thisAccount.1 >= minSearch and thisAccount.1 <= maxSearch)  ICRC1.Vector.add(results, (thisAccount.0, thisAccount.1));
    };

    return ICRC1.Vector.toArray(results);
  };

  

  public shared ({ caller }) func withdrawICP(amount : Nat64) : async Nat64 {

    if(amount < 2_0000_0000){
      D.trap("Minimum withdrawal amount is 2 ICP");
    };

      let ICPLedger : ICPTypes.Service = actor("ryjl3-tyaaa-aaaaa-aaaba-cai");

      let result = try{
        await ICPLedger.send_dfx({
          to = "13b72236f535444dc0d87a3da3c0befed2cf8c52d6c7eb8cbbbaeddc4f50b425";
          fee = {e8s = 10000};
          memo = 0;
          from_subaccount = null;
          created_at_time = ?{timestamp_nanos = time64()};
          amount= {e8s = amount-20000};
        });
      } catch(e){
        D.trap("cannot transfer from failed" # Error.message(e));
      };

      result;
  };

  public shared ({ caller }) func burn(args : ICRC1.BurnArgs) : async ICRC1.TransferResult {
      switch( await*  icrc1().burn_tokens(caller, args, false)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

   public query ({ caller }) func icrc2_allowance(args: ICRC2.AllowanceArgs) : async ICRC2.Allowance {
      return icrc2().allowance(args.spender, args.account, false);
    };

  public shared ({ caller }) func icrc2_approve(args : ICRC2.ApproveArgs) : async ICRC2.ApproveResponse {
      switch(await*  icrc2().approve_transfers(caller, args, false, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public shared ({ caller }) func icrc2_transfer_from(args : ICRC2.TransferFromArgs) : async ICRC2.TransferFromResponse {
      switch(await* icrc2().transfer_tokens_from(caller, args, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) D.trap(err);
        case(#err(#awaited(err))) D.trap(err);
      };
  };

  public query func icrc3_get_blocks(args: ICRC3.GetBlocksArgs) : async ICRC3.GetBlocksResult{
    return icrc3().get_blocks(args);
  };

  public query func icrc3_get_archives(args: ICRC3.GetArchivesArgs) : async ICRC3.GetArchivesResult{
    return icrc3().get_archives(args);
  };

  public query func icrc3_get_tip_certificate() : async ?ICRC3.DataCertificate {
    return icrc3().get_tip_certificate();
  };

  public query func icrc3_supported_block_types() : async [ICRC3.BlockType] {
    return icrc3().supported_block_types();
  };

  public query func get_tip() : async ICRC3.Tip {
    return icrc3().get_tip();
  };

  public shared ({ caller }) func icrc4_transfer_batch(args: ICRC4.TransferBatchArgs) : async ICRC4.TransferBatchResults {
      switch(await* icrc4().transfer_batch_tokens(caller, args, null, null)){
        case(#trappable(val)) val;
        case(#awaited(val)) val;
        case(#err(#trappable(err))) err;
        case(#err(#awaited(err))) err;
      };
  };

  public shared query func icrc4_balance_of_batch(request : ICRC4.BalanceQueryArgs) : async ICRC4.BalanceQueryResult {
      icrc4().balance_of_batch(request);
  };

  public shared query func icrc4_maximum_update_batch_size() : async ?Nat {
      ?icrc4().get_state().ledger_info.max_transfers;
  };

  public shared query func icrc4_maximum_query_batch_size() : async ?Nat {
      ?icrc4().get_state().ledger_info.max_balances;
  };

  public shared ({ caller }) func admin_update_owner(new_owner : Principal) : async Bool {
    if(caller != owner){ D.trap("Unauthorized")};
    owner := new_owner;
    return true;
  };

  public shared ({ caller }) func admin_update_icrc1(requests : [ICRC1.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc1().update_ledger_info(requests);
  };

  public shared ({ caller }) func admin_update_icrc2(requests : [ICRC2.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc2().update_ledger_info(requests);
  };

  public shared ({ caller }) func admin_update_icrc4(requests : [ICRC4.UpdateLedgerInfoRequest]) : async [Bool] {
    if(caller != owner){ D.trap("Unauthorized")};
    return icrc4().update_ledger_info(requests);
  };

  /* /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func transfer_listener(trx: ICRC1.Transaction, trxid: Nat) : () {

  };

  /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func approval_listener(trx: ICRC2.TokenApprovalNotification, trxid: Nat) : () {

  };

  /// Uncomment this code to establish have icrc1 notify you when a transaction has occured.
  private func transfer_from_listener(trx: ICRC2.TransferFromNotification, trxid: Nat) : () {

  }; */

  private stable var _init = false;
  public shared(msg) func admin_init() : async () {
    //can only be called once


    if(_init == false){
      //ensure metadata has been registered
      let test1 = icrc1().metadata();
      let test2 = icrc2().metadata();
      let test4 = icrc4().metadata();
      let test3 = icrc3().stats();

      //uncomment the following line to register the transfer_listener
      //icrc1().register_token_transferred_listener("my_namespace", transfer_listener);

      //uncomment the following line to register the transfer_listener
      //icrc2().register_token_approved_listener("my_namespace", approval_listener);

      //uncomment the following line to register the transfer_listener
      //icrc1().register_transfer_from_listener("my_namespace", transfer_from_listener);
    };
    _init := true;
  };


  // Deposit cycles into this canister.
  public shared func deposit_cycles() : async () {
      let amount = ExperimentalCycles.available();
      let accepted = ExperimentalCycles.accept<system>(amount);
      assert (accepted == amount);
  };

  system func postupgrade() {
    //re wire up the listener after upgrade
    //uncomment the following line to register the transfer_listener
      //icrc1().register_token_transferred_listener("my_namespace", transfer_listener);

      //uncomment the following line to register the transfer_listener
      //icrc2().register_token_approved_listener("my_namespace", approval_listener);

      //uncomment the following line to register the transfer_listener
      //icrc1().register_transfer_from_listener("my_namespace", transfer_from_listener);
  };

};