/*##############################################################################

    HPCC SYSTEMS software Copyright (C) 2012 HPCC Systems.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
############################################################################## */

import Std.File AS FileServices;
import $;

boolean createMultiPart := (__PLATFORM__[1..4] = 'thor');

Files := $.files(createMultiPart, FALSE);

FetchData   := DATASET([
    {3000,   'FL', 'Boca Raton',  'London',   'Bridge'},
    {3500,   'FL', 'Boca Raton',  'Anderson', 'Sue'},
    {3500,   'FL', 'Boca Raton',  'Anderson', 'John'},
    {35,     'FL', 'Boca Raton',  'Smith',    'Frank'},
    {3500,   'FL', 'Boca Raton',  'Johnson',  'Joe'},
    {50,     'FL', 'Boca Raton',  'Smith',    'Sue'},
    {135,    'FL', 'Boca Raton',  'Smith',    'Nancy'},
    {3500,   'FL', 'Boca Raton',  'Johnson',  'Sue'},
    {235,    'FL', 'Boca Raton',  'Smith',    'Fred'},
    {335,    'FL', 'Boca Raton',  'Taylor',   'Frank'},
    {3500,   'FL', 'Boca Raton',  'Johnson',  'Jane'},
    {3500,   'FL', 'Boca Raton',  'Jones',    'Frank'},
    {3500,   'FL', 'Boca Raton',  'Jones',    'Tommy'},
    {3500,   'FL', 'Boca Raton',  'Doe',        'John'},
    {3500,   'FL', 'Boca Raton',  'Anderson', 'Joe'},
    {3500,   'FL', 'Boca Raton',  'Doe',        'Jane'},
    {3500,   'FL', 'Boca Raton',  'Doe',        'Joe'},
    {3500,   'FL', 'Boca Raton',  'Johnson',  'Larry'},
    {3500,   'FL', 'Boca Raton',  'Johnson',  'John'},
    {3500,   'FL', 'Boca Raton',  'Anderson', 'Larry'},
    {3500,   'FL', 'Boca Raton',  'Anderson', 'Jane'},
    {30,     'FL', 'Boca Raton',  'Smith',      'Zeek'}], Files.DG_FetchRecord);

// Try to make sure that there are at least 2 parts with data on... This gets a little hairy in places!
// Note that in order to facilitate testing of preload / preloadIndexed versions of data, we generate the same file under 3 names

twoways := distribute(FetchData, IF(lname < 'Jom', 0, 1));
output(sort(twoways,record,local),,Files.DG_FetchFileName,OVERWRITE);
output(sort(twoways,record,local),,Files.DG_FetchFilePreloadName,OVERWRITE);
output(sort(twoways,record,local),,Files.DG_FetchFilePreloadIndexedName,OVERWRITE);

sortedFile := SORT(Files.DG_FETCHFILE, Lname,Fname,state ,__filepos, LOCAL);
BUILDINDEX(sortedFile,{Lname,Fname},{STRING tfn := TRIM(Fname), state, STRING100 blobfield {blob}:= fname+lname, __filepos},Files.DG_FetchIndex1Name, OVERWRITE, SORTED);

//This is only used to perform a keydiff.
BUILDINDEX(sortedFile,{Lname,Fname},{STRING tfn := TRIM(Fname), state, STRING100 blobfield {blob}:= fname+lname, __filepos},Files.DG_FetchIndex2Name, OVERWRITE, SORTED);

//A version of the index with LName/FName transposed and x moved to the front.
BUILDINDEX(sortedFile,{Fname,Lname},{STRING100 blobfield {blob}:= fname+lname, STRING tfn := TRIM(Fname), state, __filepos},Files.DG_FetchTransIndexName, OVERWRITE);

fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchFilePreloadName, '', '', 'view', '1:1', false);
fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchFilePreloadIndexedName, '', '', 'view', '1:1', false);

fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchIndex1Name, '', '', 'view', '1:1', false);
fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchIndex1Name, '__fileposition__', '__filepos', 'link', '1:1', true);
fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchIndex2Name, '', '', 'view', '1:1', false);
fileServices.AddFileRelationship( Files.DG_FetchFileName, Files.DG_FetchIndex2Name, '__fileposition__', '__filepos', 'link', '1:1', true);

//Optionally Create local versions of the indexes.
LocalFiles := $.Files(createMultiPart, TRUE);
IF (createMultiPart,
    PARALLEL(
        BUILDINDEX(sortedFile,{Lname,Fname},{STRING tfn := TRIM(Fname), state, STRING100 blobfield {blob}:= fname+lname, __filepos},LocalFiles.DG_FetchIndex1Name, OVERWRITE, SORTED, NOROOT);
        BUILDINDEX(sortedFile,{Lname,Fname},{STRING tfn := TRIM(Fname), state, STRING100 blobfield {blob}:= fname+lname, __filepos},LocalFiles.DG_FetchIndex2Name, OVERWRITE, SORTED, NOROOT);
        BUILDINDEX(sortedFile,{Fname,Lname},{STRING100 blobfield {blob}:= fname+lname, STRING tfn := TRIM(Fname), state, __filepos},LocalFiles.DG_FetchTransIndexName, OVERWRITE, NOROOT);
   )
);
