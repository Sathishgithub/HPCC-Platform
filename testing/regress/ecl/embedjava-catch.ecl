//nothor

//Thor doesn't handle CATCH properly, see HPCC-9059
//skip type==thorlcr TBD

IMPORT java;

integer testThrow(integer p) := IMPORT(java, 'JavaCat.testThrow:(I)I');

// Can't catch an expression(only a dataset)
d := dataset([{ 1, '' }], { integer a, string m} ) : stored('nofold');

d t := transform
  self.a := FAILCODE;
  self.m := FAILMESSAGE;
  self := [];
end;

catch(d(testThrow(a) = a), onfail(t));
