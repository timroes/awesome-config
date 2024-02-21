import * as awful from 'awful';
import * as wibox from 'wibox';
import * as gears from 'gears';
import { dpi } from '../lib/dpi';
import { theme } from '../theme/default';
import { ICON_PATH, SUPER } from '../lib/constants';
import { execute, isCommandAvailable } from '../lib/process';

interface ScreenInfo {
  id: string;
  connected: boolean;
  primary: boolean;
  internal: boolean;
}

interface ScreenLayout {
  name: string;
  icons: {
    internal: boolean;
    external: boolean;
  };
  fn: (screens: ScreenInfo[]) => Promise<void>;
}

let switcher: awful.Popup | null;
let focusedOption = 0;
let isMultiScreen: boolean = false;

const screenLayouts: ScreenLayout[] = [
  {
    name: "Laptop",
    icons: {
      internal: true,
      external: false,
    },
    fn: async (screens: ScreenInfo[]) => {
      const internal = screens.find(s => s.internal);
      if (internal) {
        await execute(`xrandr --output ${internal.id} --auto --primary ${screens.filter(s => !s.internal).map(s => `--output ${s.id} --off`).join(" ")}`);
      }
    }
  },
  {
    name: "Externals",
    icons: {
      internal: false,
      external: true,
    },
    fn: async (screens: ScreenInfo[]) => {
      const connectedExternals = screens.filter(s => s.connected && !s.internal);
      if (connectedExternals.length > 0) {
        await execute(`xrandr --output ${connectedExternals[0].id} --auto --primary ${connectedExternals.slice(1).map(s => `--left-of ${s.id} --output ${s.id} --auto`).join(" ")} ${screens.filter(s => !connectedExternals.includes(s)).map(s => `--output ${s.id} --off`).join(" ")}`);
      }
    }
  },
  {
    name: "Extend",
    icons: {
      internal: true,
      external: true,
    },
    fn: async (screens: ScreenInfo[]) => {
      const allConnected = screens.filter(s => s.connected);
      if (allConnected.length > 0) {
        await execute(`xrandr --output ${allConnected[0].id} --auto --primary ${allConnected.slice(1).map(s => `--left-of ${s.id} --output ${s.id} --auto`).join(" ")} ${screens.filter(s => !s.connected).map(s => `--output ${s.id} --off`).join(" ")}`);
      }
    }
  },
];

async function getScreenInfos(): Promise<ScreenInfo[]> {
  const { stdout: output } = await execute("xrandr -q");
  return output?.split("\n").filter(line => line.includes("normal")).map(line => {
    const id = line.split(" ")[0];
    return {
      id,
      connected: !line.includes("disconnected"),
      primary: line.includes("primary"),
      internal: id === "eDP-1", // No better way at the moment to determine if a screen is internal
    };
  }) ?? [];
}

function createLayoutItem(s: Screen, layout: ScreenLayout, focused: boolean, disabled: boolean){
  const laptopImage = gears.color.recolor_image(`${ICON_PATH}/display-internal-${layout.icons.internal ? "enabled" : "disabled"}.png`, focused ? theme.text.dark : theme.text.light);
  const externalImage = gears.color.recolor_image(`${ICON_PATH}/display-external-${layout.icons.external ? "enabled" : "disabled"}.png`, focused ? theme.text.dark : theme.text.light);
  return (
    <wibox.container.background bg={focused ? theme.highlight.regular : theme.bg.panel} fg={focused ? theme.text.dark : theme.text.light} shape={gears.shape.rounded_rect} opacity={disabled ? 0.2 : 1}>
      <wibox.container.margin left={dpi(10, s)} right={dpi(10, s)} top={dpi(5, s)} bottom={dpi(5, s)}>
        <wibox.layout.align.horizontal>
          {null}
          <wibox.widget.textbox text={layout.name} />
          <wibox.layout.fixed.horizontal spacing={dpi(3, s)}>
            <wibox.widget.imagebox image={laptopImage} forced_height={24} forced_width={24} opacity={layout.icons.internal ? 1 : 0.5} />
            <wibox.widget.imagebox image={externalImage} forced_height={24} forced_width={24} opacity={layout.icons.external ? 1 : 0.5}  />
          </wibox.layout.fixed.horizontal>
        </wibox.layout.align.horizontal>
      </wibox.container.margin>
    </wibox.container.background>
  );
}

function createWidget(screen: Screen) {
  return wibox.widget(
    <wibox.container.margin left={dpi(8, screen)} right={dpi(8, screen)} top={dpi(10, screen)} bottom={dpi(10, screen)}>
      <wibox.layout.fixed.vertical spacing={dpi(8, screen)} forced_width={dpi(200, screen)}>
        {...screenLayouts.map((layout, i) => createLayoutItem(screen, layout, focusedOption === i, !isMultiScreen && i !== 0))}
      </wibox.layout.fixed.vertical>
    </wibox.container.margin>
  );
}

isCommandAvailable("xrandr").then(() => {
  awful.keygrabber({
    root_keybindings: [[[SUPER], "p", async () => {
      const screens = await getScreenInfos();
      isMultiScreen = screens.filter(s => s.connected && !s.internal).length > 0;
      switcher = awful.popup({
        type: "dialog",
        visible: true,
        screen: screen.primary,
        bg: theme.bg.base,
        ontop: true,
        placement: awful.placement.centered,
        widget: createWidget(screen.primary),
      });
    }]],
    keypressed_callback(modifiers, key, event) {
      switch (key) {
        case "Return":
        case "Enter":
          getScreenInfos().then(async (screens) => {
            await screenLayouts[focusedOption].fn(screens);
            this.stop();
          });
          break;
        case "Up":
          if (!isMultiScreen) return;
          focusedOption = (focusedOption - 1) % 3;
          switcher!.widget = createWidget(screen.primary);
          break;
        case "Down":
        case "p":
          if (!isMultiScreen) return;
          focusedOption = (focusedOption + 1) % 3;
          switcher!.widget = createWidget(screen.primary);
          break;
        case "Escape":
          this.stop();
          break;
      }
    },
    stop_callback() {
      focusedOption = 0;
      switcher!.visible = false;
      switcher = null;
    }
  });
});
