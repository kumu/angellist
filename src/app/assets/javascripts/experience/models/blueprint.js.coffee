mixins =
    # follower counts
    count: {settings: {pooled: false, core: false, single: true}} # format: 'number'
    
    # social profiles
    url: {settings: {core: true, pooled: false, single: true, format: 'url'}}


blueprint =
    defaults:
        directed: true # set to false for release
    
    theme:
        # mapsheet / stylesheet: # ... should set stylesheet here
        
        # behaviors
        magnifier: false
        scaleLabels: false

        # default appearance / theme
        fontColor: '#AAAAAA'
        fontFamily: "'Helvetica Neue'"
        backgroundColor: '#222222'
        elementSize: 30
    
    attributes:
        'Element Type':
            values: ['Startup', 'User', 'Market', 'Location']
        
        'Connection Type':
            values: ['Founder', 'Investor', 'Advisor', 'Employee']
        
        'Media':
            settings: {pooled: false, core: false, single: false, format: 'blurb'}
        
        'Image': 
            settings: {pooled: false, core: true, single: true, format: 'url'}
        
        # break these two out so we show them in the attributes list as well as the social profiles toolbar
        'Profile': 
            settings: {pooled: false, core: true, single: true, format: 'url'}
        
        'Website':
            settings: {pooled: false, core: true, single: true, format: 'url'}
        
        'Markets':
            settings: {pooled: true, core: false, single: false, format: 'tag'}
        
        'Locations':
            settings: {pooled: true, core: false, single: false, format: 'tag'}
        
        # counts
        'Investor Follower Count': mixins.count
        'Follower Count': mixins.count
        'Startup Count': mixins.count
        'User Count': mixins.count
        
        # tags define aggregate total counts as well
        'Total Investor Follower Count': mixins.count
        'Total Follower Count': mixins.count
        'Total Startup Count': mixins.count
        'Total User Count': mixins.count
        
        # social profiles
        'Facebook Profile': mixins.url
        'Twitter Profile': mixins.url
        'LinkedIn Profile': mixins.url
        'GitHub Profile': mixins.url
        'YouTube Profile': mixins.url
        'AngelList Profile': mixins.url
        
        'Duration':
            settings: {pooled: false, single: true}
    
    perspectives:
        'Base': [
            {collection: 'elements', selector: 'market, location', declarations: {visibility: 'hidden'}}
            {collection: 'elements', selector: 'market', declarations: {imageUrl: '/assets/experience/market-scope.png'}}
            {collection: 'elements', selector: 'location', declarations: {imageUrl: '/assets/experience/location.png'}}
            {label: 'Founder', collection: 'connections', selector: 'founder-connection', declarations: {color: '#00ACED'}}
            {label: 'Investor', collection: 'connections', selector: 'investor-connection', declarations: {color: '#ECC935'}}
            {label: 'Employee', collection: 'connections', selector: 'employee-connection', declarations: {}}
            {label: 'Advisor', collection: 'connections', selector: 'advisor-connection', declarations: {pattern: 'dashed'}}
        ]
        
        'Basic Perspective':
            summary: '',
            rules: [
                # {collection: 'elements', selector: 'element', declarations: {visibility: 'hidden'}}
            ]
        
        'Scaled by Popularity':
            summary: 'Elements scaled by popularity',
            rules: [
                {legend: off, collection: 'elements', selector: 'element', declarations: {scale: {expression: 'followerCount', range: [0.5, 2]}}}
            ]

        'With Markets and Locations':
            summary: 'Elements scaled by popularity',
            rules: [
                # TODO: add support for extending other perspectives so we don't have to duplicate the rules
                {collection: 'elements', selector: 'market, location', declarations: {visibility: 'visible'}}
                {legend: off, collection: 'elements', selector: 'element', declarations: {scale: {expression: 'followerCount', range: [0.5, 2]}}}
            ]


namespace 'AngellistExperience', (exports) ->
	exports.blueprint = blueprint