urlShortener = softwareSystem "Url Shortener" "..." {
    !include url-shortener.dsl
}

urlShortener --https-> analyticsPlatform "Sends analytics to"

linkCreator = person "Link Creator" "Creates and manages short links; needs click statistics and reliability." "User"
linkCreator --https-> urlShortener "Creates and manages short links; views stats"

linkVisitor = person "Link Visitor" "Follows short links and expects fast redirects with minimal friction." "User"
linkVisitor --https-> urlShortener "Clicks short links to redirect"

apiDeveloper = person "API Developer" "Integrates with the shortening API/SDK to create links programmatically." "Engineering"
apiDeveloper --https-> urlShortener "Shortens links via API"

shortenerAdmin = person "Administrator/Support" "Operates the service, monitors SLOs, handles abuse/takedowns, and support." "Ops"
shortenerAdmin --https-> urlShortener "Administers, monitors, and supports"
