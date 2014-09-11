# Description:
# Update wheel repo for 1%Club.
#
# Commands:
# hubot wheel me <project>

{spawn, exec} = require 'child_process'

projectDirs =
    onepercent: '/var/www/onepercentclub-site'
    booking: '/var/www/booking'

module.exports = (robot) ->
    # Update wheel repo
    robot.respond /wheel me (onepercent|booking)?/i, (msg) ->
        # Get site directory
        siteDir = projectDirs[msg.match[1]]

        # Restrict environments for deployment
        unless siteDir.match
            sendMsg msg, "Sorry, you can only wheel onepercent or booking."
            return

        sendMsg msg, "Preparing to wheel some packages from #{siteDir}..."

        # Display current branch
        exec "/bin/bash -l -c 'cd #{siteDir} && source ./env/bin/activate && pip wheel --allow-all-external --allow-unverified django-admin-tools -r requirements/ci_requirements.txt --wheel-dir=/var/www/wheelhouse'", (err, stdout, stderr) ->
            if err
                sendMsg msg, "Sorry, could not update wheel repo. #{err}"
            else
                sendMsg msg, "Done!"

sendMsg = (msg, text) ->
    msg.send "--> #{text}"
