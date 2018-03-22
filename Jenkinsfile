#!groovy
import groovy.transform.Field;

// Executes a build across each of the following providers, for each of the
// given boxes
List providers = [
    'qemu'
];

@Field List systems = [
    'fedora-rawhide-x86_64',
    'ubuntu-17.10-amd64',
];

// Since the provider is called "qemu" but outputs a box called "libvirt", as
// that is the actual virtualbox provider in use, we need to be able to
// transform the name of the provider we're building for into the name of the
// box that it was building
@Field def providerTransform = [
    qemu: 'libvirt',
    virtualbox: 'virtualbox'
];

// Performs all the builds of the boxes for a single provider. It can be run
// in parallel across multiple providers, so long as they're not all spinning
// up on the same host at once. Generally each set of virtualization software
// can only run by itself, and we can't really get multiple of them building
// all at once on the same piece of hardware
def build(String provider) {
	return {
		stage(provider) {
			node(provider) {
				cleanWs();
				checkout scm;
				for(String system : systems) {
					sh "packerio build -only=${provider} -var headless=true ${system}.json";
				}
			}
		}
	};
}

// Create the jobs for each provider, and then run them in parallel
def providerJobs = [:];
for(String provider : providers) {
	providerJobs[provider] = build(provider);
}
parallel providerJobs
