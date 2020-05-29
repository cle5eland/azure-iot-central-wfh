# Working Remotely with Azure IoT Central

With the current global health crisis, the way we approach our daily tasks--including work--is changing. I've put together this documentation of how I've managed the transition to remote work in hope that other members of our team can benefit.

If you're an intern reading this: Welcome! We are incredibly excited to have you on board, and, on behalf of the entire IoT Solutions Team, thank you for working with us as we figure out the best way to support you guys from afar.

## Goal

Laptops often aren't powerful enough to run our local environment in a developer-friendly way. If you don't have a desktop machine to RDP to (or, as in my case, don't enjoy coding through RDP), this solution allows you to leverage the computing power of an Azure VM, while still enjoying a native development experience.

## Guide

### Prerequisites

1. If you are on Windows, make sure you have a unix-like shell available to you. I recommend using a unix console emulator like [cmder](https://cmder.net/), but if you are familiar with [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10), that should work too (it's awesome, I just haven't tried it specifically for this guide). The rest of this guide assumes you are working in a unix-like environment.
1. [Visual Studio Code](https://code.visualstudio.com/download).
1. For interns/new hires--make sure you have your access configured, your github account linked appropriately, DockerHub account created, etc. before going through this guide. Work with your manager/mentor to get this all set up correctly.

### Set up Visual Studio Enterprise subscription with your MSDN Account

1. Go to the Visual Studio Enterprise Subscription [Management Page](https://my.visualstudio.com/benefits)
1. Login with your Microsoft Work Account (if you're an intern and either have not set this up or are getting Permission Denied, ask your manager)
1. Under "Azure \$150 monthly credit" hit "Activate"
   ![](./assets/AzureMonthlyCredit.png)
1. Enter the email of your personal MSDN Account (NOT your work email) and follow the steps.

### Create a VM

Next, we are going to provision the guts of our development environment. I have put together a script to do this for you automatically.

1. Install Azure CLI for your operating system by following the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
1. Clone this repo
1. From your shell, run `az login`, and follow the prompts to login with your MSDN Account (Not your microsoft account).
1. From your shell, navigate to the `local` directory under this project, and run `sh ./provisionVM.sh`. The location defaults to West US, but feel free to change it to something closer to you (the list of valid location values will be listed for your convenience). This will provision your machine and generate all the scripts you'll need to use on the day-to-day in the `local/user` directory.

### Set up your VM to run IoT Central

Okay, great! We have our machine. Next, let's get IoT Central running.

1. Navigate to the local/user folder.
1. Run `sh startWFH.sh`
1. You'll be ssh-ed into your new machine. These next set of instructions will all be on this remote machine.
1. Clone this repo.
