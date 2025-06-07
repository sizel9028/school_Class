% Truss 구조체 생성

Truss = struct();
Truss.nodes = [];
Truss.members = [];
Truss.loads = [];
Truss.A = [];
Truss.E = [];
Truss.status = "determinate";
Truss.supports = [];
Truss.memForces = [];

% Beam 구조체 생성, elementBeam 구조체 생성, 내부힌지는 고려 X

Beam = struct();
elementBeam = struct();
Force = struct();

elementBeam.nodes = [];
elementBeam.reactions = [];
elementBeam.supports = [];
elementBeam.startNode = [];
elementBeam.endNode = [];

Force.startpoint = [];
Force.endpoint = [];
Force.type = {};
Force.eqn = {};
Force.M = [];
Force.power = [];

elementBeam.Force = Force;

lineBeam = elementBeam; 

Beam.lineBeam = repmat(elementBeam, 0, 1); 
Beam.dummyNodes = [];

% 자료구조 생성

Stack = {};
Queue = {};

% 전역변수 초기화

global statusFlag
statusFlag = "Truss";
global exitFlag
exitFlag = false;