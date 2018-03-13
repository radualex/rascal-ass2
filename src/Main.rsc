module Main

import Prelude;
import IO;
import util::ValueUI;
import JavaToObjectFlow;
import flow::ObjectFlow;
import lang::java::m3::TypeSymbol;
import Relation;
import analysis::m3::Core;
import analysis::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public M3 projectM3;
public FlowProgram projectProgram;
public OFG programOfg;

void main()
{
	loc exampleProject = |project://Assignment2/src/javaFiles|;
	CreateM3AndOFG(exampleProject);	
	//Find superClasses for every class.
	//Find primitives (object instead of primitives as super class).
	
	println(projectM3.extends);
	OFG classes = GetOFGClassDependency();
	OFG interfaces = GetOFGInterfaceDependency();
	//CreateSuggestions(classes, interfaces);
	//for(e <- classes)
	//{
	//	println(e);
	//}	
	//
	//println();
	//for(e <- interfaces)
	//{
	//	println(e);
	//}	
}

void CreateM3AndOFG(loc projectLoc)
{
	projectM3 = createM3FromEclipseProject(projectLoc); 
	set[Declaration] asts = createAstsFromEclipseProject(projectLoc, true);
	projectProgram = createOFG(asts);
	programOfg = buildFlowGraph(projectProgram);
}

OFG GetOFGClassDependency()
{
	OFG typedVariables = {pair | pair <- projectM3.typeDependency, pair[1].scheme == "java+class" || pair[1].scheme == "java+primitiveType"};
	OFG classes = {};
	for(e <- typedVariables)
	{
		classes += propagate(programOfg, {e}, {}, false);
	}
	classes = {pair | pair <- classes, pair[0].scheme == "java+field" || pair[0].scheme == "java+variable"};
	return classes;
}

OFG GetOFGInterfaceDependency()
{
	OFG interfaceDependency = {pair | pair <- projectM3.typeDependency, pair[1].scheme == "java+interface" && (pair[0].scheme == "java+field" || pair[0].scheme == "java+variable") };
	return interfaceDependency;
}

void CreateSuggestions(OFG classDependency, OFG interfaceDependency)
{
	for(e <- interfaceDependency)
	{
		for(f <- classDependency)
		{
			if(f[0] == e[0])
			{
				println(f[0]);
				println(f[1]); //type
				println(e[1]); //interface (Map, list, etc)
				println();
			}
		}
	}
}
