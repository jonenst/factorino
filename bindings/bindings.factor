USING: alien.c-types alien.libraries alien.syntax ;
IN: factorino.bindings

<<
"rec_robotino_com_c" 
"/data/trunk/openrobotino1/target/librec_robotino_com_c.so"
"cdecl" add-library
>>

LIBRARY: rec_robotino_com_c

CONSTANT: INVALID_ANALOGINPUTID -1
CONSTANT: INVALID_BUMPERID -1
CONSTANT: INVALID_CAMERAID -1
CONSTANT: INVALID_COMID -1
CONSTANT: INVALID_DIGITALINPUTID -1
CONSTANT: INVALID_DIGITALOUTPUTID -1
CONSTANT: INVALID_DISTANCESENSORID -1
CONSTANT: INVALID_ENCODERINPUTID -1
CONSTANT: TRUE 1
CONSTANT: FALSE 0
CONSTANT: NULL 0
CONSTANT: INVALID_GRIPPERID -1
CONSTANT: INVALID_INFOID -1
CONSTANT: INVALID_MOTORID -1
CONSTANT: INVALID_NORTHSTARID -1
CONSTANT: INVALID_ODOMETRYID -1
CONSTANT: INVALID_OMNIDRIVEID -1
CONSTANT: INVALID_POWERMANAGEMENTID -1
CONSTANT: INVALID_POWEROUTPUTID -1
CONSTANT: INVALID_RELAYID -1

TYPEDEF: int AnalogInputId
TYPEDEF: int BumperId
TYPEDEF: int CameraId
TYPEDEF: int ComId
TYPEDEF: int DigitalInputId
TYPEDEF: int DigitalOutputId
TYPEDEF: int DistanceSensorId
TYPEDEF: int EncoderInputId
TYPEDEF: int BOOL
TYPEDEF: int GripperId
TYPEDEF: int InfoId
TYPEDEF: int MotorId
TYPEDEF: int NorthStarId
TYPEDEF: int OdometryId
TYPEDEF: int OmniDriveId
TYPEDEF: int PowerManagementId
TYPEDEF: int PowerOutputId
TYPEDEF: int RelayId

FUNCTION: AnalogInputId AnalogInput_construct ( uint n ) ;
FUNCTION: BOOL AnalogInput_destroy ( AnalogInputId id ) ;
FUNCTION: BOOL AnalogInput_setComId ( AnalogInputId id, ComId comId ) ;
FUNCTION: uint numAnalogInputs ( ) ;
FUNCTION: float AnalogInput_value ( AnalogInputId id ) ;

FUNCTION: BumperId Bumper_construct ( ) ;
FUNCTION: BOOL Bumper_destroy ( BumperId id ) ;
FUNCTION: BOOL Bumper_setComId ( BumperId id, ComId comId ) ;
FUNCTION: BOOL Bumper_value ( BumperId id ) ;

FUNCTION: CameraId Camera_construct ( ) ;
FUNCTION: BOOL Camera_destroy ( CameraId id ) ;
FUNCTION: BOOL Camera_setComId ( CameraId id, ComId comId ) ;
FUNCTION: BOOL Camera_grab ( CameraId id ) ;
FUNCTION: BOOL Camera_imageSize ( CameraId id, uint* width, uint* height ) ;
FUNCTION: BOOL Camera_getImage ( CameraId id, uchar* imageBuffer, uint imageBufferSize, uint* width, uint* height ) ;
FUNCTION: BOOL Camera_setStreaming ( CameraId id, BOOL streaming ) ;

FUNCTION: ComId Com_construct ( ) ;
FUNCTION: BOOL Com_destroy ( ComId id ) ;
FUNCTION: BOOL Com_setAddress ( ComId id,  c-string address ) ;
FUNCTION: BOOL Com_address ( ComId id, c-string* addressBuffer, uint addressBuffersSize ) ;
FUNCTION: BOOL Com_setImageServerPort ( ComId id, int port ) ;
FUNCTION: BOOL Com_connect ( ComId id ) ;
FUNCTION: BOOL Com_disconnect ( ComId id ) ;
FUNCTION: BOOL Com_isConnected ( ComId id ) ;

FUNCTION: DigitalInputId DigitalInput_construct ( uint n ) ;
FUNCTION: BOOL DigitalInput_destroy ( DigitalInputId id ) ;
FUNCTION: BOOL DigitalInput_setComId ( DigitalInputId id, ComId comId ) ;
FUNCTION: uint numDigitalInputs ( ) ;
FUNCTION: BOOL DigitalInput_value ( DigitalInputId id ) ;

FUNCTION: DigitalOutputId DigitalOutput_construct ( uint n ) ;
FUNCTION: BOOL DigitalOutput_destroy ( DigitalOutputId id ) ;
FUNCTION: BOOL DigitalOutput_setComId ( DigitalOutputId id, ComId comId ) ;
FUNCTION: uint numDigitalOutputs ( ) ;
FUNCTION: BOOL DigitalOutput_setValue ( DigitalOutputId id, BOOL on ) ;

FUNCTION: DistanceSensorId DistanceSensor_construct ( uint n ) ;
FUNCTION: BOOL DistanceSensor_destroy ( DistanceSensorId id ) ;
FUNCTION: BOOL DistanceSensor_setComId ( DistanceSensorId id, ComId comId ) ;
FUNCTION: uint numDistanceSensors ( ) ;
FUNCTION: float DistanceSensor_voltage ( DistanceSensorId id ) ;
FUNCTION: uint DistanceSensor_heading ( DistanceSensorId id ) ;

FUNCTION: EncoderInputId EncoderInput_construct ( ) ;
FUNCTION: BOOL EncoderInput_destroy ( EncoderInputId id ) ;
FUNCTION: BOOL EncoderInput_setComId ( EncoderInputId id, ComId comId ) ;
FUNCTION: BOOL EncoderInput_resetPosition ( EncoderInputId id ) ;
FUNCTION: int EncoderInput_position ( EncoderInputId id ) ;
FUNCTION: int EncoderInput_velocity ( EncoderInputId id ) ;

FUNCTION: GripperId Gripper_construct ( ) ;
FUNCTION: BOOL Gripper_destroy ( GripperId id ) ;
FUNCTION: BOOL Gripper_setComId ( GripperId id, ComId comId ) ;
FUNCTION: BOOL Gripper_open ( GripperId id ) ;
FUNCTION: BOOL Gripper_close ( GripperId id ) ;
FUNCTION: BOOL Gripper_isOpened ( GripperId id ) ;
FUNCTION: BOOL Gripper_isClosed ( GripperId id ) ;

FUNCTION: InfoId Info_construct ( ) ;
FUNCTION: BOOL Info_destroy ( InfoId id ) ;
FUNCTION: BOOL Info_setComId ( InfoId id, ComId comId ) ;
FUNCTION: BOOL Info_text ( InfoId id, c-string* infoBuffer, uint infoBuffersSize ) ;
FUNCTION: BOOL Info_isPassiveMode ( InfoId id ) ;

FUNCTION: MotorId Motor_construct ( uint number ) ;
FUNCTION: BOOL Motor_destroy ( MotorId id ) ;
FUNCTION: BOOL Motor_setComId ( MotorId id, ComId comId ) ;
FUNCTION: uint numMotors ( ) ;
FUNCTION: BOOL Motor_setSetPointSpeed ( MotorId id, float speed ) ;
FUNCTION: BOOL Motor_resetPosition ( MotorId id ) ;
FUNCTION: BOOL Motor_setBrake ( MotorId id, BOOL brake ) ;
FUNCTION: BOOL Motor_setPID ( MotorId id, float kp, float ki, float kd ) ;
FUNCTION: float Motor_actualSpeed ( MotorId id ) ;
FUNCTION: int Motor_actualPosition ( MotorId id ) ;
FUNCTION: float Motor_motorCurrent ( MotorId id ) ;
FUNCTION: float Motor_rawCurrentMeasurment ( MotorId id ) ;

FUNCTION: NorthStarId NorthStar_construct ( ) ;
FUNCTION: BOOL NorthStar_destroy ( NorthStarId id ) ;
FUNCTION: BOOL NorthStar_setComId ( NorthStarId id, ComId comId ) ;
FUNCTION: uint NorthStar_sequenceNo ( NorthStarId id ) ;
FUNCTION: int NorthStar_roomId ( NorthStarId id ) ;
FUNCTION: uint NorthStar_numSpotsVisible ( NorthStarId id ) ;
FUNCTION: int NorthStar_posX ( NorthStarId id ) ;
FUNCTION: int NorthStar_posY ( NorthStarId id ) ;
FUNCTION: float NorthStar_posTheta ( NorthStarId id ) ;
FUNCTION: uint NorthStar_magSpot0 ( NorthStarId id ) ;
FUNCTION: uint NorthStar_magSpot1 ( NorthStarId id ) ;
FUNCTION: BOOL NorthStar_setRoomId ( NorthStarId id, int roomId ) ;
FUNCTION: BOOL NorthStar_setCalState ( NorthStarId id, uint calState ) ;
FUNCTION: BOOL NorthStar_setCalFlag ( NorthStarId id, uint calFlag ) ;
FUNCTION: BOOL NorthStar_setCalDistance ( NorthStarId id, uint calDistance ) ;
FUNCTION: BOOL NorthStar_setCeilingCal ( NorthStarId id, float ceilingCal ) ;

FUNCTION: OdometryId Odometry_construct ( ) ;
FUNCTION: BOOL Odometry_destroy ( OdometryId id ) ;
FUNCTION: BOOL Odometry_setComId ( OdometryId id, ComId comId ) ;
FUNCTION: float Odometry_x ( OdometryId id ) ;
FUNCTION: float Odometry_y ( OdometryId id ) ;
FUNCTION: float Odometry_phi ( OdometryId id ) ;
FUNCTION: BOOL Odometry_set ( OdometryId id, float x, float y, float phi ) ;

FUNCTION: OmniDriveId OmniDrive_construct ( ) ;
FUNCTION: BOOL OmniDrive_destroy ( OmniDriveId id ) ;
FUNCTION: BOOL OmniDrive_setComId ( OmniDriveId id, ComId comId ) ;
FUNCTION: BOOL OmniDrive_setVelocity ( OmniDriveId id, float vx, float vy, float omega ) ;
FUNCTION: BOOL OmniDrive_project ( OmniDriveId id, float* m1, float* m2, float* m3, float vx, float vy, float omega ) ;

FUNCTION: PowerManagementId PowerManagement_construct ( ) ;
FUNCTION: BOOL PowerManagement_destroy ( PowerManagementId id ) ;
FUNCTION: BOOL PowerManagement_setComId ( PowerManagementId id, ComId comId ) ;
FUNCTION: float PowerManagement_current ( PowerManagementId id ) ;
FUNCTION: float PowerManagement_voltage ( PowerManagementId id ) ;

FUNCTION: PowerOutputId PowerOutput_construct ( ) ;
FUNCTION: BOOL PowerOutput_destroy ( PowerOutputId id ) ;
FUNCTION: BOOL PowerOutput_setComId ( PowerOutputId id, ComId comId ) ;
FUNCTION: BOOL PowerOutput_setValue ( PowerOutputId id, float setPoint ) ;
FUNCTION: float PowerOutput_current ( PowerOutputId id ) ;
FUNCTION: float PowerOutput_rawCurrentMeasurment ( PowerOutputId id ) ;

FUNCTION: RelayId Relay_construct ( uint number ) ;
FUNCTION: BOOL Relay_destroy ( RelayId id ) ;
FUNCTION: BOOL Relay_setComId ( RelayId id, ComId comId ) ;
FUNCTION: uint numRelays ( ) ;
FUNCTION: BOOL Relay_setValue ( RelayId id, BOOL on ) ;

