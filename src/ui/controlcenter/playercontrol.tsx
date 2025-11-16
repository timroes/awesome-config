import * as wibox from "wibox";
import * as gears from "gears";
import * as awful from "awful";

import { ControlWidget } from "./control-widget";
import { theme } from "../../theme/default";
import { ICON_PATH } from "../../lib/constants";
import { dpi } from "../../lib/dpi";
import { dbus } from "../../lib/dbus";
import { MouseButton } from "../../lib/mouse";
import { LogLevel, log } from "../../lib/log";

interface MediaPlayer2Changed {
  PlaybackStatus?: "Paused" | "Playing" | "Stopped";
  Metadata?: {
    "xesam:album"?: string;
    "xesam:title"?: string;
    "xesam:artist"?: string[];
  };
  CanPause?: boolean;
  CanPlay?: boolean;
  CanGoNext?: boolean;
}

const PLAY_ICON = `${ICON_PATH}/player-play.png`;
const PAUSE_ICON = `${ICON_PATH}/player-pause.png`;

export class PlayerControl extends ControlWidget {
  private playbackStatus: MediaPlayer2Changed["PlaybackStatus"] = "Stopped";
  private metadata?: MediaPlayer2Changed["Metadata"];

  private playPause(): void {
    dbus.session().call("org.mpris.MediaPlayer2.playerctld", "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", "PlayPause", []);
  }

  private next(): void {
    dbus.session().call("org.mpris.MediaPlayer2.playerctld", "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", "Next", []);
  }

  private updateNoMusicPlaying(): void {
    (this.currentRender.get_children_by_id("metadata")[0] as TextBox).markup =
      `<span style='italic' weight='light' color='${theme.text.subdued}'>No music playing</span>`;
  }

  private updatePlaybackStatus(playbackStatus: MediaPlayer2Changed["PlaybackStatus"]): void {
    this.playbackStatus = playbackStatus;
    (this.currentRender.get_children_by_id("play")[0] as Imagebox).image = gears.color.recolor_image(
      playbackStatus === "Playing" ? PAUSE_ICON : PLAY_ICON,
      theme.text.subdued
    );
    if (playbackStatus === "Stopped" && !this.metadata?.["xesam:title"]) {
      this.updateNoMusicPlaying();
    }
  }

  private updateCanPlay(canPlay: boolean): void {
    (this.currentRender.get_children_by_id("play")[0] as Imagebox).visible = canPlay;
  }

  private updateCanGoNext(canGoNext: boolean): void {
    (this.currentRender.get_children_by_id("next")[0] as Imagebox).visible = canGoNext;
  }

  private updateMetadata(metadata: NonNullable<MediaPlayer2Changed["Metadata"]>): void {
    this.metadata = metadata;
    if (this.playbackStatus === "Stopped" && (metadata["xesam:title"] === undefined || metadata["xesam:title"].length === 0)) {
      this.updateNoMusicPlaying();
    } else {
      const markup = `<b>${gears.string.xml_escape(metadata["xesam:title"] ?? "")}</b>\n${metadata["xesam:artist"]?.map((a) => gears.string.xml_escape(a)).join(", ")}`;
      (this.currentRender.get_children_by_id("metadata")[0] as TextBox).markup = markup;
      this.handler.requestRelayout();
    }
  }

  override onInit(): void {
    this.updateNoMusicPlaying();

    dbus
      .session()
      .onSignal<
        [string, MediaPlayer2Changed]
      >(null, "org.freedesktop.DBus.Properties", "PropertiesChanged", "/org/mpris/MediaPlayer2", (event) => {
        if (event.params[1].Metadata) {
          this.updateMetadata(event.params[1].Metadata);
        }
        if (event.params[1].PlaybackStatus) {
          this.updatePlaybackStatus(event.params[1].PlaybackStatus);
        }
        if (event.params[1].CanPlay !== undefined) {
          this.updateCanPlay(event.params[1].CanPlay);
        }
        if (event.params[1].CanGoNext !== undefined) {
          this.updateCanGoNext(event.params[1].CanGoNext);
        }
      });

    dbus
      .session()
      .getProperty<string>(
        "org.mpris.MediaPlayer2.playerctld",
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "PlaybackStatus"
      )
      .then((playbackStatus) => {
        this.updatePlaybackStatus(playbackStatus as MediaPlayer2Changed["PlaybackStatus"]);
      });

    dbus
      .session()
      .getProperty<boolean>("org.mpris.MediaPlayer2.playerctld", "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", "CanPlay")
      .then((canPlay) => {
        this.updateCanPlay(canPlay);
      });

    dbus
      .session()
      .getProperty<boolean>("org.mpris.MediaPlayer2.playerctld", "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", "CanGoNext")
      .then((canGoNext) => {
        this.updateCanGoNext(canGoNext);
      });

    dbus
      .session()
      .getProperty<MediaPlayer2Changed["Metadata"]>(
        "org.mpris.MediaPlayer2.playerctld",
        "/org/mpris/MediaPlayer2",
        "org.mpris.MediaPlayer2.Player",
        "Metadata"
      )
      .then((metadata) => {
        if (metadata) {
          this.updateMetadata(metadata);
        }
      });
  }

  override onKeyPress(modifiers: Modifier[], key: string): void {
    switch (key) {
      case " ":
        this.playPause();
        break;
      case "n":
        this.next();
        break;
    }
  }

  override render(s: Screen): WidgetDefinition {
    return (
      <wibox.container.background shape={gears.shape.rounded_rect} bg={theme.controlcenter.panel}>
        <wibox.container.margin margins={dpi(8, s)}>
          <wibox.layout.align.horizontal spacing={dpi(8, s)}>
            <wibox.widget.imagebox
              image={gears.color.recolor_image(`${ICON_PATH}/music.png`, theme.text.subdued)}
              forced_height={dpi(24, s)}
              forced_width={dpi(24, s)}
            />
            <wibox.container.margin left={dpi(6, s)} right={dpi(6, s)}>
              <wibox.widget.textbox markup="" ellipsize="end" id="metadata" />
            </wibox.container.margin>
            <wibox.layout.fixed.horizontal spacing={dpi(8, s)}>
              <wibox.widget.imagebox
                id="play"
                image={gears.color.recolor_image(PLAY_ICON, theme.text.subdued)}
                buttons={awful.button([], MouseButton.PRIMARY, () => this.playPause())}
                forced_height={dpi(20, s)}
                visible={false}
              />
              <wibox.widget.imagebox
                id="next"
                image={gears.color.recolor_image(`${ICON_PATH}/player-next.png`, theme.text.subdued)}
                buttons={awful.button([], MouseButton.PRIMARY, () => this.next())}
                forced_height={dpi(20, s)}
                visible={false}
              />
            </wibox.layout.fixed.horizontal>
          </wibox.layout.align.horizontal>
        </wibox.container.margin>
      </wibox.container.background>
    );
  }
}
