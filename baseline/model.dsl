baselineSystem = softwareSystem "Baseline System" "A system that does something." {
}

baselinePerson = person "Baseline Person" "A person that does something." 
baselinePerson --https-> baselineSystem "Uses the system to do something."