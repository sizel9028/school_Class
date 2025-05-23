Truss = struct();
Truss.nodes = [];
Truss.members = [];
Truss.loads = [];
Truss.A = 1;
Truss.E = 1e9;
Truss.status = "determinate";
Truss.supports = [];
Truss.memForces = [];

Stack = {};
Queue = {};

global exitFlag
exitFlag = false;