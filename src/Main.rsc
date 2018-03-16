module Main

import DataExtractor;
import SuggestionsCreator;
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
public loc exampleProject = |project://Assignment2/src/javaFiles|;

void main(loc projectLocation)
{
	int startTime = realTime();

	CreateM3AndOFG(projectLocation);	
	
    Extends = GetExtends(projectM3);
    Extends = Extends + GetPrimitiveTypes(projectM3);
	OFG classes = GetOFGClassDependency(projectM3, programOfg);
	OFG interfaces = GetOFGInterfaceDependency(projectM3);
	Suggestions = CreateSuggestions(classes, interfaces, Extends);
	DisplaySuggestions(Suggestions);	
	
	real totalTime = (realTime() - startTime) / 1000.0;
	println("Total time is: <totalTime> seconds");
}

void CreateM3AndOFG(loc projectLoc)
{
	projectM3 = createM3FromEclipseProject(projectLoc); 
	set[Declaration] asts = createAstsFromEclipseProject(projectLoc, true);
	projectProgram = createOFG(asts);
	programOfg = buildFlowGraph(projectProgram);
}
