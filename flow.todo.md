Well I want my env are; 
1. minimal ubuntu
2. npm
3. bun.sh
4. git (env managed creds)
5. gh (logged in GitHub accounts, env managed creds)
6. portainer
7. htop
8. bun i -g @anthropic-ai/claude-code
9. tmux

All should be isolated from host,especially the files the persistence, volume, so I have identical state across fresh VPS. So all should be bundelable to image for push pull to https://mega.io/ storage also the volume . But the network should all be open to host. Should be there script for everything even the mega storage pull push
