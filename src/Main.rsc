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
public map[str, str] Extends = ();
public set[tuple[loc, str, str]] Suggestions = {};

void main()
{
	loc exampleProject = |project://Assignment2/src/javaFiles|;
	CreateM3AndOFG(exampleProject);	
	
    Extends = GetSetExtends(projectM3);
    Extends = Extends + GetPrimitiveTypes(projectM3);
	OFG classes = GetOFGClassDependency();
	OFG interfaces = GetOFGInterfaceDependency();
	CreateSuggestions(classes, interfaces);
	for(s <- Suggestions)
	{
		println(s);
	}
	//Get first type for Map
	//Get types for methods
	
	//println(Extends["Book"]);
	//for(e <- Extends)
	//{
	//	println(e);
	//}
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
	classes = {pair | pair <- classes, pair[0].scheme == "java+field" || pair[0].scheme == "java+variable" || pair[0].scheme == "java+method"};
	return classes;
	
}

OFG GetOFGInterfaceDependency()
{
	OFG interfaceDependency = {pair | pair <- projectM3.typeDependency, pair[1].scheme == "java+interface" && (pair[0].scheme == "java+field" || pair[0].scheme == "java+variable" || pair[0].scheme == "java+method") };
	return interfaceDependency;
}

map[str, str] GetSetExtends(M3 m3)
{
	map[str, str] tempSet = ();
	OFG tempOFG = {pair | pair <- m3.extends};
	for(i <- tempOFG)
	{
		map[str, str] currentMap = (i[0].file : i[1].file);
		tempSet = tempSet + currentMap;
	}
	
	return tempSet;
}

map[str, str] GetPrimitiveTypes(M3 m3)
{
	map[str, str] tempSet = ();
	OFG primitives = {pair | pair <- projectM3.typeDependency, pair[1].scheme == "java+primitiveType"};
	for(p <- primitives)
	{
		if(p[1].file != "void")
		{
			map[str, str] currentMap = (p[1].file : "Object");
			if(p[1].file notin tempSet)
			{
				tempSet = tempSet + currentMap;
			}
		}
	}
	
	return tempSet;
}

void CreateSuggestions(OFG classDependency, OFG interfaceDependency)
{
	for(e <- interfaceDependency)
	{
		for(f <- classDependency)
		{
			if(f[0] == e[0])
			{
				//println(f[0]);
				//println(f[1]); //type
				//println(e[1]); //interface (Map, list, etc)
				//println();
				str currentType = f[1].file;
				if(f[1].file in Extends)
				{
					currentType = Extends[f[1].file];
				}
				
				if(f[0].scheme != "java+method")
				{				
					if(e[1].file != "Map")
					{						
						Suggestions = Suggestions + {<f[0], e[1].file, "<e[1].file>\<<currentType>\>">};
					}
					else
					{
						Suggestions = Suggestions + {<f[0], e[1].file, "<e[1].file>\<Unknown,<currentType>\>">};
					}
				}
				else
				{
					println(f[0]);
				}
			}
		}
	}
}
