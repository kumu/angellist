###
There are multiple translations of data going on here
Resource:
    The actual model on the remote service

Reference:
    A reference to the resource as returned by the API
    Reference may or may not be fully defined, sometimes doesn't even follow same attribute structure depending on endpoint.

Object:
    The resource as defined by the experience. Likely ignored many attributes, renamed some, and added our own.
    Maintains a reference to the original reference through object#data

Entity:
    Basically the same thing as the object, but with a unique eid assigned to identify the element/connection internally.
###

class Builder
    _.extend @prototype, Backbone.Events
    
    constructor: (@model) ->
        @blueprint = @model.blueprint
    
    # primary entry point
    fetch: (resource) =>
        switch resource.get('type')
            when 'Startup' then @requestStartupDetails(resource)
            when 'User' then @requestUserDetails(resource)
            when 'MarketTag', 'LocationTag' then @requestTagDetails(resource)
    
    # exploring connections of existing objects
    explore: (resource) =>
        switch resource.get('type')
            when 'Startup' then @exploreStartup(resource)
            when 'User' then @exploreUser(resource)
            when 'MarketTag', 'LocationTag' then @exploreTag(resource)
    
    ###
    private
    ###
    
    update: =>
        @model.trigger('update')
    
    exploreStartup: (startup) =>
        @requestStartupDetails(startup).then(=> @requestStartupRolesForStartup(startup))
    
    exploreUser: (user) =>
        @requestUserDetails(user).then(=> @requestStartupRolesForUser(user))
    
    exploreTag: (tag) =>
        @requestTagDetails(tag).then(=>
            @requestStartupsForTag(tag)
            #@requestUsersForTag(tag)
        )
    
    
    # details requests don't affect the map much so don't bother notifying
    requestStartupDetails: (startup) =>
        @requestWithTimeout("Unable to load details for startup #{startup}", (request) =>
            $.getJSON("https://api.angel.co/1/startups/#{startup.get('id')}?callback=?")
                .done((startup) =>
                    startup = @startup(startup)
                    
                    if startup
                        @blueprint.build.element(startup)
                        
                        markets = startup.resource.get('markets')
                        locations = startup.resource.get('locations')

                        for tag in [].concat(markets, locations)
                            tag = @tag(tag)

                            @blueprint.build.element(tag)
                            @blueprint.build.connection(startup, tag)
                        
                        request.resolve(startup)
                    else
                        request.reject()
                )
        )
    
    requestUserDetails: (user) =>
        @requestWithTimeout("Unable to load details for user #{user}", (request) =>
            $.getJSON("https://api.angel.co/1/users/#{user.get('id')}?callback=?")
                .done((user) =>
                    element = @blueprint.build.element(@user(user))
                    request.resolve(element)
                )
        )
    
    requestTagDetails: (tag) =>
        @requestWithTimeout("Unable to load details for tag #{tag}", (request) =>
            $.getJSON("https://api.angel.co/1/tags/#{tag.get('id')}?callback=?")
                .done((tag) =>
                    element = @blueprint.build.element(@tag(tag))
                    request.resolve(element)
                )
        )
    
    requestStartupRolesForStartup: (startup) =>
        @requestWithTimeout("Unable to load roles for startup #{startup}", (request) =>
            $.getJSON("https://api.angel.co/1/startups/#{startup.id}/users?callback=?")
                .done((results) =>
                    for role in results.startup_roles[0..50]
                        @blueprint.build.element(@user(role.user))
                        @blueprint.build.connection(@user(role.user), @startup(startup), @role(role))
                    
                    request.resolve()
                    
                    @update()
                )
        )
    
    requestStartupRolesForUser: (user) =>
        @requestWithTimeout("Unable to load roles for user #{user}", (request) =>
            $.getJSON("https://api.angel.co/1/startup_roles?user_id=#{user.id}&callback=?")
                .done((results) =>
                    user = @user(user)
                    
                    for role in results.startup_roles
                        startup = @startup(role.startup)
                        
                        if startup
                            role = @role(role)
                            
                            # should push role as tag on user
                            
                            @blueprint.build.element(startup)
                            @blueprint.build.connection(user, startup, role)
                    
                    
                    request.resolve()
                    
                    @update()
                )
        )
    
    requestStartupsForTag: (tag) =>
        @requestWithTimeout("Unable to load startups for tag #{tag}", (request) =>
            $.getJSON("https://api.angel.co/1/tags/#{tag.id}/startups?order=popularity&callback=?")
                .done((results) =>
                    tag = @tag(tag)
                    
                    for startup in results.startups
                        startup = @startup(startup)
                        
                        if startup
                            @blueprint.build.element(startup)
                            @blueprint.build.connection(tag, startup, {type: 'Tag'})
                    
                    request.resolve()
                    
                    @update()
                )
        )
    
    # error responses doesn't trigger any events via JSONP
    # need to handle them through a timeout instead
    requestWithTimeout: (options..., callback) =>
        dfd = new $.Deferred()
        
        message = options[0] || 'Not found. Try again!' # assumes a 404 response
        timeout = options[1] || 5000
        
        # queue the timeout
        _.delay((=> dfd.reject(message) if dfd.state() == 'pending'), timeout)
        
        # trigger the request
        callback(dfd)
        
        # return the timeout-wrapped promise
        dfd.promise()
    
    role: (role) =>
        # force resource type to be present
        role.type = 'Role'
        
        connection =
            resource: new AngellistExperience.Resource(role)
            id: role.id
            type: role.role.replace('past_', '').titleize()
            duration: if role.started_at then "#{role.started_at} to #{role.ended_at || 'Present'}" else "Unknown"
            tags: []
        
        connection.tags.push('Past') if role.role.match('past_')
        
        connection
    
    # returns nothing if startup is hidden
    startup: (startup) =>
        unless startup.hidden
            # force resource type to be present
            startup.type = 'Startup'

            element =
                resource: new AngellistExperience.Resource(startup)
                id: startup.id
                type: 'Startup'
                label: startup.name
                tags: []
                markets: []
                summary: if startup.high_concept then "**#{startup.high_concept}**  \n\n  #{startup.product_desc}" else null
                image: startup.logo_url # thumb_url?
                followerCount: startup.follower_count
                website: startup.company_url
                facebookProfile: startup.facebook_url
                twitterProfile: startup.twitter_url
                linkedinProfile: startup.linkedin_url
                angellistProfile: startup.angellist_url
            
            element.markets = _.pluck(startup.markets, 'display_name')
            element.locations = _.pluck(startup.locations, 'display_name')
            
            element.tags = element.markets.concat(element.locations)
            
            element
    
    user: (user) =>
        # force resource type to be present
        user.type = 'User'

        element =
            resource: new AngellistExperience.Resource(user)
            id: user.id
            type: 'User'
            label: user.name
            summary: user.bio
            profile: user.angellist_url
            image: user.image
            media: "![Image](#{user.image})"
            followerCount: user.follower_count
            facebookProfile: user.facebook_url
            twitterProfile: user.twitter_url
            linkedinProfile: user.linkedin_url
            angellistProfile: user.angellist_url
    
    tag: (tag) =>
        # force resource type to be present
        tag.type = tag.tag_type

        element =
            resource: new AngellistExperience.Resource(tag)
            id: tag.id
            type: tag.tag_type.replace('Tag', '')
            label: tag.display_name # what is tag.name?
            angellistProfile: tag.angellist_url
        
        if tag.statistics?
            stats =
                # total stats
                totalInvestorFollowerCount: tag.statistics.all.investor_followers
                totalFollowerCount: tag.statistics.all.followers
                totalStartupCount: tag.statistics.all.startups
                totalUserCount: tag.statistics.all.users
                # direct stats
                investorFollowerCount: tag.statistics.direct.investor_followers
                followerCount: tag.statistics.direct.followers
                startupCount: tag.statistics.direct.startups
                userCount: tag.statistics.direct.users
            
            _.extend(element, stats)
        
        element


namespace 'AngellistExperience', (exports) ->
    exports.Builder = Builder