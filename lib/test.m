clear ;
clc;
a = AtriPair('Name','1.89298765678876590876543212e3');
c = AtriPair('Name','2');
d = AtriPair('Name1','2');
b = a ;
Param = ParamStore;
Param.Des = 'The First Param1';
Param.addParam(a);
Param.addParam(d);
%Param.updateParam('Name','3');
%Param.writeXmlFile('test')
%rs = ParamStore.readXmlFile('test');

Param2 = ParamStore;
Param2.Des = 'The second Param2';
Param2.addParam(a);
Param2.addParam(d);
Param2.updateParam('Name','4');
Param2.updateParam('Name1','5');
PM = ParamMg([Param,Param2]);
rs = ParamMg.writeXmlFile(PM,'test');
%rs = ParamStore.getdiffer(Param,Param2);
Fecth = ParamMg.readXmlFile('test');
P = Fecth.ParamStoreArray;
length(P)
p1 = P(1) ;
uget = ParamStore.ParamStore2struct(Param);
uget2 = ParamStore.ParamStore2struct(Param2);
uget3 = ParamStore.struct2ParamStore(uget);
uget3.getParam('Name');
uget4 = ParamStore.fullfillStruct(uget,Param2)
src = struct('Name','Name','Value','2','Des','test');
src = rmfield(src,'Des');