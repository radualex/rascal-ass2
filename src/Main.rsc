module Main

import IO;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import JavaToObjectFlow;
import flow::ObjectFlow;

void main()
{
	loc exampleProject = |project://Assignment2/src/javaFiles|;
	m = createM3FromEclipseProject(exampleProject); 
	set[Declaration] asts = createAstsFromEclipseProject(exampleProject, true);
	FlowProgram p = createOFG(asts);
	OFG ofg = buildFlowGraph(p);
	//print(toList(methods(m)));
	print(p.decls);
}