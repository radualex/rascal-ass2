module Main

import IO;
import Set;
import List;
import JavaToObjectFlow;
import flow::ObjectFlow;
import vis::Figure;
import lang::java::m3::TypeSymbol;
import Relation;
import analysis::m3::Core;
import analysis::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public M3 projectM3;
public FlowProgram projectProgram;
public OFG programOfg;
public list[Edge] programOfgEdges = [];
//public set[str] programOfgNodes = {};

void main()
{
	loc exampleProject = |project://Assignment2/src/javaFiles|;
	CreateM3AndOFG(exampleProject);
	programOfgEdges = makeOfgEdges(programOfg);
	//programOfgNodes = makeOfgNodes(programOfgEdges);
	
	for(e <- programOfgEdges)
	{
		println(e);
	}
	
	//list[Edge] dependency = [edge("<to>", "<from>") | <from, to> <- projectM3@typeDependency ];
	
	//for(n <- programOfgNodes)
	//{
	//	println(n);
	//}
}

void CreateM3AndOFG(loc projectLoc)
{
	projectM3 = createM3FromEclipseProject(projectLoc); 
	set[Declaration] asts = createAstsFromEclipseProject(projectLoc, true);
	projectProgram = createOFG(asts);
	programOfg = buildFlowGraph(projectProgram);
}

list[Edge] makeOfgEdges(OFG ofg) {
    return [edge("<to>", "<from>") | <from, to> <- ofg ];
}

//set[str] makeOfgNodes(list[Edge] ofgEdges) {
//	set[str] nodes = {};
//    for (e <- ofgEdges) {
//        nodes += e.from;
//        nodes += e.to;
//    }
//    return nodes;
//}