---
title:  Multiple SSH Keys in Multiple 1Password Vaults"
categories: 
  - Security
tags:
  - cryptography
  - ssh
  - 1password
---

I like many tech folks out there hate when my machine gets too bloated, and will typically erase everything and start over on an annual basis at least. I typically go through and make sure I have all my files backed up, but more than once have I forgotten to do *something* with my SSH keys. This isn't usually a big deal - I can create new ones, and re-add them to the applications where I use them most commonly - GitLab, GitHub, etc. Re-creating them though and re-uploading them does take time, and is unnecessary.

Now you might be saying, just back up your SSH keys and move them to your new machine, and sure, that's an option - not even a bad one. This could leave my SSH keys available in a spot where I have them backed up, which generally feels less secure than it could be. My solution.... 1Password.

I have used a number of password managers over the years. Starting with [KeePass](https://keepass.info/), later moving to [LastPass](https://www.lastpass.com/), but several years ago I moved to [1Password](https://1password.com/), and haven't looked back.

1Password has an immense amount of functionality, and I am sure I am not using it to its' fullest potential, but over the past several months I have been using the SSH Agent functionality to add a layer of security, as well as facilitate the storage of my SSH keys across devices.

I have several personal projects I spend time on, and will occasionally jump in and help some friends with their projects as well. When I do this, I will occasionally create new accounts and/or SSH keys to work in their ecosystems, and now I create them within 1Password, and will often store them in a separate vault to keep my credentials for side projects separated. 

By default, the 1Password SSH agent will make every eligible key (SSH Key item type, that is not archived) in the built-in **Personal**, **Private**, or **Employee** vault of your 1Password accounts available to offer to SSH servers. This configuration is automatically set up when you [turn on the SSH agent](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent). This means right out of the box, if all of your SSH keys are in one of those bolded vaults above, you will be prompted for the key you would like to use when performing an action that requires an SSH key.

I am not always the best at reading the documentation, unless I get into trouble - and because I stored some SSH keys in a separate vault, I did run into trouble. 

By default, when you enable the SSH Agent, your `~/.ssh/config` file will get created/updated with the following line: 
```
Host *
	IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```
Now when I run a git clone command like the following, I will be prompted to use the SSH Keys that are available in my Private vault.
`git clone git@github.com:project/repo.git`

I can authorize or deny each SSH Key in the vault, only authorizing the one that should have the correct permissions. In my normal git workflow, this proved to be more disruptive than I would have liked. I also ran into issues where the SSH Key I wanted to use was not available to the agent and I could not proceed with my work.

## Using keys in other vaults
To use keys available in other vaults, the `~/.config/1Password/ssh/agent.toml` file needs to be updated. By default, the file will look similar to the following:

```
[[ssh-keys]]
vault = "Private"
```
If I saved my SSH Key in a vault called "Project Vault", I will need to add another 2 lines to the `~/.config/1Password/ssh/agent.toml` file. It will end up looking like the following:
```
[[ssh-keys]]
vault = "Private"

[[ssh-keys]]
vault = "Project Vault"
```
The above change will allow all of the SSH Keys in the vaults listed in this file to be listed as options when performing a command that utilizes SSH.

## Using the correct key
To get the correct key to be selected automatically, I needed to update my `~/.ssh/config` file to look like the following:

```
Host *
	IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

Host personalgit
	HostName github.com
	User git
	IdentityFile ~/.ssh/personal_git.pub
	IdentitiesOnly yes

# Work GitHub
Host projectgit
	HostName github.com
	User git
	IdentityFile ~/.ssh/project_git.pub
	IdentitiesOnly yes
```

The change above allows me to specify the host to use when I run commands, and when using that host, the SSH Key referenced on the `IdentityFile` line will be selected automatically. For example: 

`git clone git@projectgit:project/repo.git`

These two changes have helped me simplify my workflow, made it easier to work between machines or setup a new machine, require MFA before using an SSH key, and increased security by reducing the sharing of SSH Keys between different systems and tenants.