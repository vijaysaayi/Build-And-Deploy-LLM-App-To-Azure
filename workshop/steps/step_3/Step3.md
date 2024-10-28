# Step 3: Running Show Keys and Add Permissions Scripts

## Show Keys Script
For the app, we will pass the `Azure Open AI` and `ACA Session pool` endpoint as environment variables. To get the values that needed to be set in `src/app/.env`, run the following scripts based on the OS version you are using..

### For Linux

1. Open your terminal.
2. Navigate to the directory containing the script:
    ```bash
    cd Build-And-Deploy-LLM-App-To-Azure/workshop/steps/step_3/scripts
    ```
3. Run the script:
    ```sh
    ./get_endpoints.sh
    ```

### For Windows

1. Open Command Prompt or PowerShell.
2. Navigate to the directory containing the script:
    ```powershell
    cd Build-And-Deploy-LLM-App-To-Azure/workshop/steps/step_3/scripts
    ```
3. Run the script:
    ```cmd
    ./get_endpoints.ps1
    ```

## Add Permissions Script
The user also needs permissions to access these resources. The least permissions needed are:
1. Azure Open AI  - "Cognitive Services OpenAI User"
2. ACA Session pool - "Azure ContainerApps Session Executor"

### For Linux

1. Open your terminal.
2. Navigate to the directory containing the script:
    ```bash
    cd Build-And-Deploy-LLM-App-To-Azure/workshop/steps/step_3/scripts
    ```
3. Run the script:
    ```bash
    ./add-permissions.sh
    ```

### For Windows

1. Open Command Prompt or PowerShell.
2. Navigate to the directory containing the script:
    ```powershell
    cd Build-And-Deploy-LLM-App-To-Azure/workshop/steps/step_3/scripts
    ```
3. Run the script:
    ```powershell
    add-permissions.ps1
    ```
