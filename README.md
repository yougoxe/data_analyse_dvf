# Data analysis DVF (FR)

Sources : ``https://www.data.gouv.fr/fr/datasets/demandes-de-valeurs-foncieres/``

This script allows you to download data files from the provided links and perform SHA-1 hash verification. It supports both Linux and Windows environments.

## Prerequisites

- For Linux: `bash`, `wget`, `git` should be installed on your system.
- For Windows: `PowerShell`, `git` should be installed on your system.

## Setup and Usage

### Linux

1. Open a terminal.
2. Clone the repository:

```bash
git clone https://github.com/yougoxe/data_analyse_dvf.git
```
3. Navigate into the project
```bash
cd data_analyse_dvf
```

4. Make it executable
```bash
chmod +x setup.sh
```

5. Run the setup script
```bash
./setup.sh
```

6. Follow the prompts to select the desired versions and proceed with the downloads.

### Windows

1. Open a Powershell session.
2. Clone the repository:

```ps1
git clone https://github.com/yougoxe/data_analyse_dvf.git
```
3. Navigate into the project
```ps1
cd data_analyse_dvf
```

4. Run the setup script
```ps1
.\setup.ps1
```

5. Follow the prompts to select the desired versions and proceed with the downloads.


## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please feel free to submit a pull request or open an issue on the repository.

