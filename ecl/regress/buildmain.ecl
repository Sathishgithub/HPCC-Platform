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

namesRecord :=
        RECORD
string20            forename;
string20            surname;
string2             nl{virtual(fileposition)};
        END;

mainRecord :=
        RECORD
integer8            sequence;
string20            forename;
string20            surname;
        END;

d := PIPE('pipeRead 500000 20', namesRecord);

mainRecord t(namesRecord l, unsigned4 c) :=
    TRANSFORM
        SELF.sequence := c;
        SELF := l;
    END;

seqd := project(d, t(left, counter));

output(seqd,,'~keyed.d00',overwrite);

