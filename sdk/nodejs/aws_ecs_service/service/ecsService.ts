// *** WARNING: this file was generated by Pulumi SDK Generator. ***
// *** Do not edit by hand unless you're certain you know what you are doing! ***

import * as pulumi from "@pulumi/pulumi";
import * as utilities from "../../utilities";

import {CodeDeploy} from "../blue_green";
import {EcrImage} from "./index";

export class EcsService extends pulumi.ComponentResource {
    /** @internal */
    public static readonly __pulumiType = 'ipidp:aws_ecs_service/service:EcsService';

    /**
     * Returns true if the given object is an instance of EcsService.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    public static isInstance(obj: any): obj is EcsService {
        if (obj === undefined || obj === null) {
            return false;
        }
        return obj['__pulumiType'] === EcsService.__pulumiType;
    }

    public /*out*/ readonly codeDeploy!: pulumi.Output<CodeDeploy | undefined>;
    public /*out*/ readonly ecrImage!: pulumi.Output<EcrImage | undefined>;

    /**
     * Create a EcsService resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args?: EcsServiceArgs, opts?: pulumi.ComponentResourceOptions) {
        let resourceInputs: pulumi.Inputs = {};
        opts = opts || {};
        if (!opts.id) {
            resourceInputs["codeDeploy"] = undefined /*out*/;
            resourceInputs["ecrImage"] = undefined /*out*/;
        } else {
            resourceInputs["codeDeploy"] = undefined /*out*/;
            resourceInputs["ecrImage"] = undefined /*out*/;
        }
        opts = pulumi.mergeOptions(utilities.resourceOptsDefaults(), opts);
        super(EcsService.__pulumiType, name, resourceInputs, opts, true /*remote*/);
    }
}

/**
 * The set of arguments for constructing a EcsService resource.
 */
export interface EcsServiceArgs {
}