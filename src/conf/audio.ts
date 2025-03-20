import * as lunaconf from "lunaconf";
import { addKey } from '../lib/keys';
import { SUPER } from '../lib/constants';
import { execute, isCommandAvailable, spawn } from '../lib/process';
import { BarModal } from "../ui/bar-modal";

const modal = new BarModal('volume.png');

async function getDefaultSink() {
  const { stdout } = await execute("pactl get-default-sink");
  return (stdout ?? "").trim();
}

async function showAudioState(defaultSink?: string) {
  const sink = defaultSink ?? await getDefaultSink();
  const [{ stdout: mutedRaw }, { stdout: volumeRaw }] = await Promise.all([
    execute(`pactl get-sink-mute ${sink}`),
    execute(`pactl get-sink-volume ${sink}`),
  ]);
  const muted = mutedRaw?.includes('yes') ?? true;
  const volume = volumeRaw ? Number(string.match(volumeRaw, " (%d+)%% ")[0] ?? 0) : 0;
  modal.setIcon(muted ? "volume-off.png" : "volume.png");
  modal.setValue(volume);
  modal.show();
}

async function changeVolume(step: number) {
  const sink = await getDefaultSink();
  await execute(`pactl set-sink-volume ${sink} ${step > 0 ? `+${step}%` : `${step}%`}`);
  showAudioState(sink);
}

addKey([], 'XF86AudioRaiseVolume', () => changeVolume(2));
addKey([], 'XF86AudioLowerVolume', () => changeVolume(-2));
addKey([], 'XF86AudioMute', async () => {
  const sink = await getDefaultSink();
  await execute(`pactl set-sink-mute ${sink} toggle`);
  showAudioState(sink);
});

addKey([], 'XF86AudioPlay', () => spawn('playerctl play-pause'));
addKey([], 'XF86AudioNext', () => spawn('playerctl next'));
addKey([], 'XF86AudioPrev', () => spawn('playerctl previous'));
addKey([ SUPER ], 'XF86AudioPlay', async () => {
  const { stdout } = await execute(`playerctl metadata --format '{{title}} ({{artist}})'`);
  lunaconf.notify.show_or_update('audio.show_metadata', {
    title: 'Currently playing',
    text: (stdout ?? "").trim(),
    icon: 'audio-speakers',
    timeout: 3,
    ignore_dnd: true,
  })
});