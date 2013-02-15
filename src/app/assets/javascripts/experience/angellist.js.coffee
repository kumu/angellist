# TODO: need to figure out a better solution to these variables
@Rails = {env: 'development'}

@currentUser = new User({name: 'Guest'})
@currentAccount = new Account({virtual: true, name: 'Experience'})
@currentWorkspace = new Workspace()
@currentMembership = new Membership({role: 'observer'})
@able = new Able(@currentMembership)

$(->
	$experience = $('#experience')

	experience = new AngellistExperience.Experience({el: $experience})
	experience.render()
)