# Description:
# Deploy branches for 1%Club.
#
# Commands:
# hubot deploy <commit> to <environment>

{spawn, exec} = require 'child_process'

deploySites =
    deploy: '/var/www/onepercentclub-site'
    bk_deploy: '/var/www/booking'
    reef_deploy: '/var/www/reef'

module.exports = (robot) ->
    # Deploy to staging
    robot.respond /(deploy|bk_deploy|reef_deploy) ([a-z|0-9]+)(\s+to\s+([a-z|0-9]+))?/i, (msg) ->
        sendMsg msg, "Checking settings..."

        # Get site deploy directory
        siteDir = deploySites[msg.match[1]]

        # Get branch and environoment details
        if msg.match[4]
            branch = msg.match[2].trim()
            env = msg.match[4].trim()
        else
            env = msg.match[2].trim()
            sendMsg msg, "Deploying #{env} without specific commit"

        # Restrict environments for deployment
        unless env.match /\b(testing|dev|staging)\b/
            sendMsg msg, "Sorry, you can only deploy dev, testing or staging."
            return

        sendMsg msg, "Preparing to deploy now..."

        # TODO: if staging then we should checkout the latest release branch
        #       if a commit provided then checkout the commit
        git_clean = "git fetch origin && git reset --hard origin/HEAD && git clean -f"
        git_cmd = "git pull"
        if branch
            git_cmd = "git checkout #{branch}"

        exec "cd #{siteDir} && echo `#{git_clean} && #{git_cmd} | grep now\ at`", (err, stdout, stderr) ->
            if err
                sendMsg msg, "Sorry, could not reset / pull branch. #{err}"
            else
                sendMsg msg, stdout

        # Display current branch
        exec "cd #{siteDir} && echo `git status | grep On\\ branch`", (err, stdout, stderr) ->
            if err
                sendMsg msg, "Sorry, could not get current branch. #{err}"
            else
                sendMsg msg, stdout

        # Execute a fabric command
        fabBranch = if branch then ":#{branch}" else ""
        exec "/bin/bash -c 'cd #{siteDir} && source env/bin/activate && fab deploy_#{env}#{fabBranch}'", (err, stdout, stderr) ->
            if err
                sendMsg msg, "Sorry, something has gone wrong. #{err}"
            else
                tag = "(no tag)"
                tagMatch = stdout.match(/^.*\[new tag\].*\b(staging|testing)\b-(\d+)/)
                if tagMatch && tagMatch.length == 3
                     tag = "(tag:#{tagMatch[1]}-#{tagMatch[2]})"
                
                branchName = (if branch then " #{branch}" else "")
                sendMsg msg, "Success:#{branchName} deployed to #{env} #{tag}"

sendMsg = (msg, text) ->
    msg.send "--> #{text}"
