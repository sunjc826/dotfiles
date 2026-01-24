// Fix process.execPath when running node via ld-linux wrapper (WSL1 workaround)
// Point execPath to the wrapper script so child_process.fork() uses the wrapper
if (process.env.DOTFILES_NODE_WRAPPER) {
  Object.defineProperty(process, 'execPath', {
    value: process.env.DOTFILES_NODE_WRAPPER,
    writable: true,
    configurable: true
  });
}
