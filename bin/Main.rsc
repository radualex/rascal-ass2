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
import util::Benchmark;

public M3 projectM3;
public FlowProgram projectProgram;
public OFG programOfg;
public map[str, str] Extends = ();
public set[tuple[loc, str, str, str]] Suggestions = {};

void main()
{
	int startTime = realTime();
	loc exampleProject = |project://Assignment2/src/javaFiles|;
	CreateM3AndOFG(exampleProject);	
	
    Extends = GetSetExtends(projectM3);
    Extends = Extends + GetPrimitiveTypes(projectM3);
	OFG classes = GetOFGClassDependency();
	OFG interfaces = GetOFGInterfaceDependency();
	CreateSuggestions(classes, interfaces);
	DisplaySuggestions(Suggestions);
	
	real totalTime = (realTime() - startTime) / 1000.0;
	println("Total time is: <totalTime> seconds");
	
	
	//OFG returnTypes = {pair | pair <- programOfg, contains(pair[1].path, "Map") || contains(pair[0].path, "Map")};
	//OFG maps = {};
	//for(e <- returnTypes)
	//{
	//	maps += propagate(programOfg, {e}, {}, false);
	//}
	//for(r <- maps)
	//{
	//	println(r);
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
	//Get suggestions for variables and fields
	for(e <- interfaceDependency)
	{
		for(f <- classDependency)
		{
			if(f[0] == e[0])
			{				
				//Get superType
				str currentType = f[1].file;
				if(f[1].file in Extends)
				{
					currentType = Extends[f[1].file];
				}
				
				if(f[0].scheme != "java+method")
				{				
					if(e[1].file != "Map")
					{											
						Suggestions = Suggestions + {<f[0], e[1].file, "<currentType>", "<e[1].file>\<<currentType>\>">};
					}
					else
					{
						Suggestions = Suggestions + {<f[0], e[1].file, "<currentType>" ,"<e[1].file>\<-,<currentType>\>">};
					}
				}
			}
		}
	}
	
	//Get suggestions for methods
	for(e <- interfaceDependency)
	{
		for(f <- classDependency)
		{
			if(f[0] == e[0])
			{
				if(f[0].scheme == "java+method")
				{	
					list[str] lines = readFileLines(f[0]);
					str firstLine = lines[0];

					if(contains(firstLine, "List") || contains(firstLine, "Map") || contains(firstLine, "Iterator") || contains(firstLine, "Collection"))
					{
						for(s <- Suggestions)
						{
							if(contains(s[0].path, f[0].path))
							{
								if(contains(firstLine, s[1]))
								{
									str currentType = s[2];
									if(currentType != "Map")
									{
										Suggestions = Suggestions + {<f[0], s[1], "<currentType>" ,"<s[1]>\<<currentType>\>">};
									}
									else
									{
										Suggestions = Suggestions + {<f[0], s[1], "<currentType>" ,"<s[1]>\<-, <currentType>\>">};
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

void DisplaySuggestions(set[tuple[loc, str, str, str]] suggestions)
{
	println("We have found <size(suggestions)> suggestions");
	for(s <- suggestions)
	{
		println("At location <s[0].path>, the type <s[1]> should be replaced with <s[3]>."); 
	}
}
