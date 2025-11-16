import { XProperties } from "../lib/constants";

// Register all xproperties that might be needed in further config files

awesome.register_xproperty(XProperties.FLOATING, "boolean");
awesome.register_xproperty(XProperties.NO_DECORATION, "boolean");
awesome.register_xproperty(XProperties.DOCK, "boolean");
for (const animation of Object.values(XProperties.ANIMATIONS)) {
  awesome.register_xproperty(animation, "boolean");
}
