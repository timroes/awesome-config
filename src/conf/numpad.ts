import { isCommandAvailable, spawn } from "../lib/process";

isCommandAvailable("numlockx").then(() => spawn("numlockx on"));
