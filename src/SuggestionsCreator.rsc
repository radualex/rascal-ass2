module SuggestionsCreator

import Prelude;
import IO;
import JavaToObjectFlow;
import flow::ObjectFlow;

set[tuple[loc, str, str, str]] CreateSuggestions(OFG classDependency, OFG interfaceDependency, map[str, str] extends)
{
	set[tuple[loc, str, str, str]] suggestions = {};
	//Get suggestions for variables and fields
	for(iD <- interfaceDependency)
	{
		for(cD <- classDependency)
		{
			if(cD[0] == iD[0])
			{				
				//Get superType
				str currentType = cD[1].file;
				if(currentType in extends)
				{
					currentType = extends[currentType];
				}
				
				if(cD[0].scheme != "java+method")
				{				
					if(iD[1].file != "Map")
					{											
						suggestions = suggestions + {<cD[0], iD[1].file, "<currentType>", "<iD[1].file>\<<currentType>\>">};
					}
					else
					{
						suggestions = suggestions + {<cD[0], iD[1].file, "<currentType>" ,"<iD[1].file>\<-,<currentType>\>">};
					}
				}
			}
		}
	}
	
	//Get suggestions for methods
	for(iD <- interfaceDependency)
	{
		for(cD <- classDependency)
		{
			if(cD[0] == iD[0])
			{
				if(cD[0].scheme == "java+method")
				{	
					list[str] lines = readFileLines(cD[0]);
					str firstLine = lines[0];

					if(contains(firstLine, "List") || contains(firstLine, "Map") || contains(firstLine, "Iterator") || contains(firstLine, "Collection"))
					{
						for(s <- suggestions)
						{
							if(contains(s[0].path, cD[0].path))
							{
								
								list[str] splitFirstLine = split(" ", firstLine); //get return type (assumption 3)
								if(splitFirstLine[1] == s[1])
								{
									str currentType = s[2];
									if(currentType != "Map")
									{
										suggestions = suggestions + {<cD[0], s[1], "<currentType>" ,"<s[1]>\<<currentType>\>">};
									}
									else
									{
										suggestions = suggestions + {<cD[0], s[1], "<currentType>" ,"<s[1]>\<-, <currentType>\>">};
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
	return suggestions;
}

void DisplaySuggestions(set[tuple[loc, str, str, str]] suggestions)
{
	println("We have found <size(suggestions)> suggestions");
	for(s <- suggestions)
	{
		println("At location <s[0].path>, the type <s[1]> should be replaced with <s[3]>."); 
	}
}