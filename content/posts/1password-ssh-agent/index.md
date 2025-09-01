+++
date = '2024-10-14T12:00:00-07:00'
draft = false
title = 'Streamlining SSH Key Management with 1Password'
aliases = ['/security/1password-ssh-agent/']
summary = "Fed up with losing SSH keys during my annual machine rebuilds, I discovered 1Password's SSH Agent functionality. With some configuration tweaks, I now manage keys securely across devices and projects while adding MFA protection to every SSH operation."
genres = ['Security', 'Productivity', 'Development', 'Tools']
tags = ['1password', 'ssh keys', 'password manager', 'security', 'productivity', 'development']
[params]
  author = 'Matt Goodrich'
+++

**Like many developers, I hate bloated machines.** I rebuild everything from scratch at least annually, carefully backing up files but inevitably forgetting *something* related to my SSH keys. Sure, I can generate new keys and re-upload them to GitHub, GitLab, etc., but that takes time and is completely unnecessary.

**You might think: "Just back up your SSH keys."** That works, but it means keys live in backup locations that feel less secure than they should. **My solution? 1Password.**

**I've migrated through the usual password manager progression:** KeePass → LastPass → 1Password. **1Password won and I haven't looked back.**

**1Password has functionality I'm probably not even aware of,** but recently I've been using its SSH Agent feature to both secure my keys and sync them across devices. **It adds MFA protection to every SSH operation while eliminating the machine rebuild headache.**

**Managing multiple projects creates key management complexity.** Between personal projects and helping friends with their systems, I often need separate accounts and SSH keys for different ecosystems. **Now I create all keys directly in 1Password and store them in separate vaults to maintain clear boundaries between projects.** 

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