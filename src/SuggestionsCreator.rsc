module SuggestionsCreator

import Prelude;
import IO;
import JavaToObjectFlow;
import flow::ObjectFlow;

set[tuple[loc, str, str, str]] CreateSuggestions(OFG classDependency, OFG interfaceDependency, map[str, str] extends)
{
	set[tuple[loc, str, str, str]] suggestions = {};
	//Get suggestions for variables and fields
	for(e <- interfaceDependency)
	{
		for(f <- classDependency)
		{
			if(f[0] == e[0])
			{				
				//Get superType
				str currentType = f[1].file;
				if(f[1].file in extends)
				{
					currentType = extends[f[1].file];
				}
				
				if(f[0].scheme != "java+method")
				{				
					if(e[1].file != "Map")
					{											
						suggestions = suggestions + {<f[0], e[1].file, "<currentType>", "<e[1].file>\<<currentType>\>">};
					}
					else
					{
						suggestions = suggestions + {<f[0], e[1].file, "<currentType>" ,"<e[1].file>\<-,<currentType>\>">};
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
						for(s <- suggestions)
						{
							if(contains(s[0].path, f[0].path))
							{
								if(contains(firstLine, s[1]))
								{
									str currentType = s[2];
									if(currentType != "Map")
									{
										suggestions = suggestions + {<f[0], s[1], "<currentType>" ,"<s[1]>\<<currentType>\>">};
									}
									else
									{
										suggestions = suggestions + {<f[0], s[1], "<currentType>" ,"<s[1]>\<-, <currentType>\>">};
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