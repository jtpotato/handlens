# Handlens 🔍

Handlens is a powerful, open-source screen recording tool that brings professional-grade zoom effects to your captures - all from the command line.

> [!WARNING]
> This project is currently a Work in Progress (WIP).

## Features

- **Dynamic Zoom Effects**: Zooms in on areas you click.
- **High-Quality Screen Recording**: Capture your screen at maximum quality and framerate.
- **Lightweight CLI**: Enjoy a fast, resource-efficient tool without the bloat of modern GUI frameworks. (_cough_ Electron _cough_)

## Why Handlens?

- **Free and Open Source**: No hidden costs or paywalls. Contribute, modify, and use as you see fit.

## Quick Start

Unfortunately, you have to build from source for now.

Once you've cloned the repository, run the following commands:

```sh
swift build -c release
cp .build/release/Handlens ~/bin/handlens
```

Make sure `~/bin` is in your PATH.

**Basic Usage**

```sh
handlens
```

That's it.

## Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions, please feel free to make a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
