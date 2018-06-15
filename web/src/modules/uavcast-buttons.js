import React, { Component } from 'react';
import RaisedButton from 'material-ui/RaisedButton';
import { START_UAVCAST, STOP_UAVCAST, AUTOSTART_UAVCAST, DISABLE_UAVCAST } from '../Events.js';
import _ from 'lodash'
const style = {
    margin: 12
};
class UavCastButtons extends Component {
    constructor(props) {
        super(props)
        this.state = {
            start: false,
            Stop: false,
            AutoStart: false,
            Disable: false
        }
    }

    render() {
        const { active, enabled, starting } = this.props
        return (
        <div className="row">
            <div className="panel-group col-sm-4">
                <div className="panel panel-primary ">
                    <div className="panel-heading">Start and stop UAVcast</div>
                    <div className="panel-body">
                        <div className="btn-toolbar">
                            <RaisedButton label={active === true ? 'Running' : starting === true ? 'Starting' : 'Start'} disabled={active || starting} primary={active} onClick={() => this.props.onSubmit(START_UAVCAST)} style={style} />
                            <RaisedButton label="Stop" primary={this.state.Stop} onClick={() => this.props.onSubmit(STOP_UAVCAST)} disabled={!(active || starting)} style={style} />
                           
                           
                        </div>
                    </div>
                </div>
            </div>   
            <div className="clearfix visible-xs-block"></div>

            <div className="panel-group col-sm-4">
                <div className="panel panel-primary ">
                    <div className="panel-heading">Enable Autostart UAVcast </div>
                    <div className="panel-body">
                        <div className="btn-toolbar">
                           
                           
                            <RaisedButton label={enabled === true ? 'AutoStart Enabled' : 'AutoStart'} primary={enabled} disabled={enabled} onClick={() => this.props.onSubmit(AUTOSTART_UAVCAST)} style={style} />
                            <RaisedButton label="Disable" onClick={() => this.props.onSubmit(DISABLE_UAVCAST)} style={style} />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        );
    }
}

export default UavCastButtons;