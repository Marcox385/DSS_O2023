echo "Hello World! at $( date +"%d/%M/%Y" )";
echo "PR Author: $PR_AUTHOR";
echo "Last commit: $PR_COMMIT";
echo -e "Commit diff:\n$( git diff HEAD^ HEAD )\n";
