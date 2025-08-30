analyticsPlatform = softwareSystem "Analytics Platform" "Tracks events from websites and provides analytics reports."

websiteVisitor = person "Website Visitor" "Generates page views and events while browsing tenant sites."
analystMarketer = person "Analyst/Marketer" "Explores reports, segmentation, and attribution analysis."
websiteOwner = person "Website Owner" "Integrates SDK and configures tracking for their websites."

websiteVisitor --sdk-> analyticsPlatform "Generates events via"
analystMarketer --https-> analyticsPlatform "Views reports and analytics from"
websiteOwner --https-> analyticsPlatform "Integrates SDK and configures"
