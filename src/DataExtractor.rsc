module DataExtractor

import Prelude;
import IO;
import analysis::m3::Core;
import analysis::m3::AST;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import JavaToObjectFlow;
import flow::ObjectFlow;


OFG GetOFGClassDependency(M3 m3, OFG ofg)
{
	OFG typedVariables = {pair | pair <- m3.typeDependency, pair[1].scheme == "java+class" || pair[1].scheme == "java+primitiveType"};
	OFG classes = {};
	for(e <- typedVariables)
	{
		classes += propagate(ofg, {e}, {}, false);
	}
	classes = {pair | pair <- classes, pair[0].scheme == "java+field" || pair[0].scheme == "java+variable" || pair[0].scheme == "java+method"};
	return classes;
	
}

OFG GetOFGInterfaceDependency(M3 m3)
{
	OFG interfaceDependency = {pair | pair <- m3.typeDependency, pair[1].scheme == "java+interface" && (pair[0].scheme == "java+field" || pair[0].scheme == "java+variable" || pair[0].scheme == "java+method") };
	return interfaceDependency;
}

map[str, str] GetExtends(M3 m3)
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
	OFG primitives = {pair | pair <- m3.typeDependency, pair[1].scheme == "java+primitiveType"};
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