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

IMPORT Python;

childrec := RECORD
   string name => unsigned value;
END;

titleRec := { string title };
titles := dataset(['', 'Mr. ', 'Rev. '], titleRec);

// Test defining a transform
transform(childrec) testTransformTitle(titleRec inrec, unsigned lim) := EMBED(Python)
  return (inrec.title, lim)
ENDEMBED;

// Test defining a transform
//MORE: The embed function shpo
transform(childrec) testTransformTitle2(_linkcounted_ row(titleRec) inrec, unsigned lim) := EMBED(Python)
  return (inrec.title, lim)
ENDEMBED;

sequential(
output(project(titles, testTransformTitle(LEFT, 10)));
output(project(titles, testTransformTitle2(LEFT, 10)));
);